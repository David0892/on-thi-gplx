#!/usr/bin/env python3
"""Build the app's question bank from the official sources.

Inputs (content/source/, see README.md for where they come from):
  bo-600-cau-hoi-2025.pdf    Bộ 600 câu hỏi, Cục CSGT 2025. Correct answer = underlined option.
  cong-van-2262-csgt-p5.pdf  Công văn 2262/CSGT-P5: Phụ lục 1 (250 câu A1/A), 2 (300 câu B1), 3 (60 câu điểm liệt).
  tool/content/rules.json    class rules and per-chapter quotas (quotas from CV 2262 section II).

Output:
  app/assets/content/content.json
  app/assets/content/img/qNNN.webp   one image per illustrated question, cropped as printed

Usage (needs pymupdf and pillow; see requirements.txt):
  python3 tool/content/build_content.py            # build + validate, exit 1 on any check failure
  python3 tool/content/build_content.py --check    # validate only, write nothing

Every check that fails is printed. Nothing is written unless all pass.
"""
import argparse
import io
import json
import re
import sys
from pathlib import Path

import pymupdf
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "content" / "source"
OUT = ROOT / "app" / "assets" / "content"
BANK = SRC / "bo-600-cau-hoi-2025.pdf"
CV = SRC / "cong-van-2262-csgt-p5.pdf"
RULES = Path(__file__).resolve().parent / "rules.json"
EXPLANATIONS = ROOT / "content" / "explanations"  # own writing: *.json, {"explanations": {"N": "..."}}

Q_RE = re.compile(r"^Câu\s+(\d+)\s*[.:]\s*(.*)$")  # Câu 507 is printed with a colon
OPT_RE = re.compile(r"^([1-4])\s*\.\s+(.*)$")
MULTI_OPT_SPLIT = re.compile(r"\s{2,}(?=[1-4]\.\s)")  # "1. Biển 1.      2. Biển 2." on one line (Câu 352)
CONSONANT_TAIL = re.compile(r"(?:^|\s)[bcdđghklmnpqrstvx]$", re.I)


def clean(s):
    return re.sub(r"\s+", " ", s).strip()


def join(prev, nxt):
    """Join two printed lines. Word sometimes breaks inside a word ("đường b" / "ộ"):
    a lone trailing consonant followed by a lowercase start is glued without a space."""
    prev, nxt = prev.rstrip(), nxt.strip()
    if not prev:
        return nxt
    if not nxt:
        return prev
    if CONSONANT_TAIL.search(prev) and nxt[0].islower():
        return prev + nxt
    return prev + " " + nxt


# ---------------------------------------------------------------- Công văn 2262

def parse_appendices(path):
    doc = pymupdf.open(path)
    text = "\n".join(p.get_text() for p in doc)
    parts = re.split(r"PHỤ LỤC\s+(\d)", text)
    apps = {}
    for i in range(1, len(parts), 2):
        num, body = int(parts[i]), parts[i + 1]
        groups, current = [], None
        for line in body.splitlines():
            s = line.strip()
            if re.match(r"^\d+\.\s+Nhóm", s):
                current = {"title": s, "numbers": []}
                groups.append(current)
            elif re.fullmatch(r"\d{1,3}", s):
                if current is None:
                    current = {"title": "(list)", "numbers": []}
                    groups.append(current)
                current["numbers"].append(int(s))
        apps[num] = groups
    return apps


# ---------------------------------------------------------------- the 600-question book

def underlined(r, underlines):
    return any(
        u.y0 >= r.y1 - 4.5 and u.y0 <= r.y1 + 1.5
        and min(u.x1, r.x1) - max(u.x0, r.x0) > min(8, r.width * 0.5)
        for u in underlines
    )


def split_options_line(page, line_rect, underlines):
    """Several options printed on one line, in any order ("1. ...   3. ..." for a two-column
    layout, Câu 301-302): a new option starts at an "N." word after a wide gap."""
    words = [w for w in page.get_text("words") if pymupdf.Rect(w[:4]).intersects(line_rect)
             and abs(w[1] - line_rect.y0) < 4]
    words.sort(key=lambda w: w[0])
    segs = []
    prev_x1 = None
    for w in words:
        gap = prev_x1 is None or w[0] - prev_x1 > 15
        prev_x1 = w[2]
        if re.fullmatch(r"[1-4]\.", w[4]) and gap:
            segs.append({"n": int(w[4][0]), "words": [], "rect": pymupdf.Rect(w[:4])})
        elif segs:
            segs[-1]["words"].append(w[4])
            segs[-1]["rect"] |= pymupdf.Rect(w[:4])
    return [{"n": sg["n"], "text": " ".join(sg["words"]), "under": underlined(sg["rect"], underlines)}
            for sg in segs]


def page_items(page):
    """Text lines and images on a page, top to bottom, with underline flags."""
    underlines = [
        g["rect"] for g in page.get_drawings()
        if g.get("fill") is not None and max(g["fill"]) < 0.35
        and g["rect"].height < 1.6 and g["rect"].width > 4
    ]
    items = []
    for b in page.get_text("dict")["blocks"]:
        if b["type"] == 1:
            items.append({"kind": "image", "bbox": pymupdf.Rect(b["bbox"])})
            continue
        for l in b["lines"]:
            text = "".join(s["text"] for s in l["spans"])
            if not text.strip():
                continue
            r = pymupdf.Rect(l["bbox"])
            items.append({"kind": "line", "bbox": r, "text": text,
                          "under": underlined(r, underlines), "underlines": underlines})
    items.sort(key=lambda it: (round(it["bbox"].y0), it["bbox"].x0))
    return items


def parse_bank(path):
    doc = pymupdf.open(path)
    questions, cur, issues = [], None, []
    for page in doc:
        if page.number < 3:  # cover, editors, preface
            continue
        for it in page_items(page):
            if it["kind"] == "image":
                if cur is None:
                    continue
                cur["images"].append((page.number, it["bbox"]))
                continue
            text, r = it["text"], it["bbox"]
            s = clean(text)
            if r.y1 < 70 and s.isdigit():  # page number
                continue
            if s.startswith("CHƯƠNG") or (s.isupper() and r.x0 > 110):  # chapter heading lines
                continue
            m = Q_RE.match(s)
            if m:
                cur = {"number": int(m.group(1)), "text": m.group(2), "opts": {}, "last": None,
                       "images": [], "page": page.number + 1}
                questions.append(cur)
                continue
            if cur is None:
                continue
            if not cur["opts"] and cur["images"] and re.fullmatch(r"[\d\s]+", s):
                # labels typed under side-by-side images ("1        2", Câu 362): part of the picture
                cur["images"].append((page.number, r))
                continue
            if len(MULTI_OPT_SPLIT.split(text.strip())) > 1 and OPT_RE.match(s):
                for o in split_options_line(page, r, it["underlines"]):
                    cur["opts"][o["n"]] = o
                    cur["last"] = o["n"]
                continue
            m = OPT_RE.match(s)
            if m and int(m.group(1)) not in cur["opts"] and (cur["opts"] or m.group(1) == "1"):
                n = int(m.group(1))
                cur["opts"][n] = {"n": n, "text": m.group(2), "under": it["under"]}
                cur["last"] = n
                continue
            # continuation of the question text or of the last option
            if cur["opts"]:
                o = cur["opts"][cur["last"]]
                o["text"] = join(o["text"], s)
                o["under"] = o["under"] or it["under"]
            else:
                cur["text"] = join(cur["text"], s)
    for q in questions:
        q["option_numbers"] = sorted(q["opts"])
        q["options"] = [q["opts"][k] for k in sorted(q["opts"])]
    return doc, questions, issues


def crop_image(doc, page_no, rect, out_path):
    pix = doc[page_no].get_pixmap(clip=rect, dpi=200)
    img = Image.open(io.BytesIO(pix.tobytes("png"))).convert("RGB")
    img.save(out_path, "WEBP", quality=82, method=6)


# ---------------------------------------------------------------- checks

def validate(questions, apps, rules):
    errors, warnings = [], []
    nums = [q["number"] for q in questions]
    if nums != list(range(1, 601)):
        missing = sorted(set(range(1, 601)) - set(nums))
        dup = sorted({n for n in nums if nums.count(n) > 1})
        errors.append(f"question numbers are not 1..600: missing={missing[:20]} duplicate={dup[:20]} count={len(nums)}")
    for q in questions:
        n = q["number"]
        if q["option_numbers"] != list(range(1, len(q["options"]) + 1)):
            errors.append(f"Câu {n}: option numbers {q['option_numbers']}")
        if not 2 <= len(q["options"]) <= 4:
            errors.append(f"Câu {n}: {len(q['options'])} options")
        marked = [i + 1 for i, o in enumerate(q["options"]) if o["under"]]
        if len(marked) != 1:
            errors.append(f"Câu {n}: underlined options = {marked}")
        if len({p for p, _ in q["images"]}) > 1:
            errors.append(f"Câu {n}: image parts on several pages")
        if not q["text"] or any(not o["text"] for o in q["options"]):
            errors.append(f"Câu {n}: empty text")
        if re.search(r"\bCâu\s+\d+\.", q["text"] + " ".join(o["text"] for o in q["options"])):
            errors.append(f"Câu {n}: swallowed another question label")

    critical = apps[3][0]["numbers"]
    if len(critical) != 60 or len(set(critical)) != 60:
        errors.append(f"Phụ lục 3 has {len(critical)} critical questions, expected 60")
    for app_no, size, crit_size in [(1, 250, 20), (2, 300, 30)]:
        groups = apps[app_no]
        pool = [n for g in groups[:-1] for n in g["numbers"]]
        crit = groups[-1]["numbers"]
        if len(pool) != size or len(set(pool)) != size:
            errors.append(f"Phụ lục {app_no}: pool has {len(pool)} ({len(set(pool))} unique), expected {size}")
        if len(crit) != crit_size:
            errors.append(f"Phụ lục {app_no}: {len(crit)} critical, expected {crit_size}")
        if not set(crit) <= set(pool):
            errors.append(f"Phụ lục {app_no}: critical not inside the pool: {sorted(set(crit) - set(pool))}")
        if not set(crit) <= set(critical):
            errors.append(f"Phụ lục {app_no}: critical not in Phụ lục 3: {sorted(set(crit) - set(critical))}")
        # the pool's own heading counts, e.g. "(100 câu trong bộ 600 câu hỏi)"
        for g in groups[:-1]:
            m = re.search(r"\((\d+) câu", g["title"])
            if m and int(m.group(1)) != len(g["numbers"]):
                errors.append(f"Phụ lục {app_no} '{g['title'][:40]}': heading says {m.group(1)}, listed {len(g['numbers'])}")

    for c in rules["classes"]:
        qs = rules["quota_sets"][c["quota_set"]]
        if sum(x["count"] for x in qs) + 1 != c["count"]:
            errors.append(f"{c['code']}: quotas + 1 critical != {c['count']}")
        if not 1 <= c["pass"] <= c["count"]:
            errors.append(f"{c['code']}: pass mark {c['pass']} out of range")

    with_img = sum(1 for q in questions if q["images"])
    if with_img < 250:
        warnings.append(f"only {with_img} questions have an image")
    return errors, warnings


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--require-all", action="store_true", help="fail unless all 600 have an explanation")
    a = ap.parse_args()

    rules = json.loads(RULES.read_text(encoding="utf-8"))
    apps = parse_appendices(CV)
    doc, questions, _ = parse_bank(BANK)
    errors, warnings = validate(questions, apps, rules)
    explanations = {}
    for f in sorted(EXPLANATIONS.glob("*.json")):
        for k, v in json.loads(f.read_text(encoding="utf-8"))["explanations"].items():
            if int(k) in explanations:
                errors.append(f"explanations: question {k} written twice (again in {f.name})")
            explanations[int(k)] = v.strip()
    unknown = sorted(set(explanations) - {q["number"] for q in questions})
    if unknown:
        errors.append(f"explanations: unknown question numbers {unknown}")
    empty = sorted(n for n, v in explanations.items() if len(v) < 20)
    if empty:
        errors.append(f"explanations: empty or too short for {empty}")
    critical_all = set(apps[3][0]["numbers"])
    missing_critical = sorted(critical_all - set(explanations))
    if missing_critical:
        errors.append(f"explanations: critical questions without explanation {missing_critical}")
    print(f"explanations: {len(explanations)}/600 (critical covered: {len(critical_all & set(explanations))}/60)")
    if a.require_all and len(explanations) != 600:
        missing = sorted(set(range(1, 601)) - set(explanations))
        errors.append(f"explanations: {len(missing)} missing, first {missing[:15]}")

    with_img = sum(1 for q in questions if q["images"])
    print(f"parsed {len(questions)} questions, {with_img} with an image")
    print(f"critical (Phụ lục 3): {len(apps[3][0]['numbers'])}")
    for w in warnings:
        print("WARN ", w)
    for e in errors:
        print("ERROR", e)
    if errors:
        print(f"{len(errors)} errors, nothing written")
        return 1
    if a.check:
        print("all checks passed (--check: nothing written)")
        return 0

    critical = set(apps[3][0]["numbers"])
    # Per class: the pool, and which of its questions count as critical for that class.
    # Phụ lục 1/2 list their own critical group (20 / 30 of the 60); a question on the
    # 60-list but filed elsewhere in the appendix is a normal question for that class
    # (each exam has exactly one critical question).
    pools = {
        "appendix1": sorted(n for g in apps[1][:-1] for n in g["numbers"]),
        "appendix1_critical": sorted(apps[1][-1]["numbers"]),
        "appendix2": sorted(n for g in apps[2][:-1] for n in g["numbers"]),
        "appendix2_critical": sorted(apps[2][-1]["numbers"]),
    }
    topic_of = {}
    for t in rules["topics"]:
        for n in range(t["from"], t["to"] + 1):
            topic_of[n] = t["id"]

    img_dir = OUT / "img"
    img_dir.mkdir(parents=True, exist_ok=True)
    for old in img_dir.glob("*.webp"):
        old.unlink()
    out_questions = []
    for q in questions:
        n = q["number"]
        image = None
        if q["images"]:
            page_no = q["images"][0][0]
            rect = pymupdf.Rect(q["images"][0][1])
            for _, r in q["images"][1:]:
                rect |= r
            image = f"img/q{n:03d}.webp"
            crop_image(doc, page_no, rect, OUT / image)
        out_questions.append({
            "n": n,
            "topic": topic_of[n],
            "critical": n in critical,
            "text": clean(q["text"]),
            "options": [clean(o["text"]) for o in q["options"]],
            "correct": next(i + 1 for i, o in enumerate(q["options"]) if o["under"]),
            "image": image,
            "explanation": explanations.get(n),
        })

    content = {
        "meta": {
            "content_version": 2,
            "bank_code": "2025",
            "is_sample": False,
            "source_ref": "Bộ 600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ, Cục Cảnh sát giao thông, 2025",
            "rules_ref": "Công văn 2262/CSGT-P5 ngày 07/5/2025 (phụ lục và cấu trúc đề); Thông tư 12/2025/TT-BCA",
            "effective_from": "2025-06-01",
            "pass_source": rules["pass_source"],
        },
        "topics": [{"id": t["id"], "name": t["name"], "short": t["short"]} for t in rules["topics"]],
        "classes": [
            {k: c[k] for k in ("code", "name", "group", "description", "count", "minutes", "pass")}
            | {"critical": 1, "verified": c["verified"], "pool": c["pool"],
               "critical_pool": None if c["pool"] == "all" else c["pool"] + "_critical",
               "quota": rules["quota_sets"][c["quota_set"]]}
            for c in rules["classes"]
        ],
        "pools": pools,
        "questions": out_questions,
    }
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "content.json").write_text(json.dumps(content, ensure_ascii=False, indent=1), encoding="utf-8")
    size = sum(p.stat().st_size for p in img_dir.glob("*.webp"))
    print(f"wrote {OUT / 'content.json'} and {with_img} images ({size / 1e6:.1f} MB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
