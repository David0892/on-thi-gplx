# Ôn thi GPLX (tên tạm)

Ứng dụng ôn thi lý thuyết giấy phép lái xe, viết bằng Flutter. Ứng dụng miễn phí, không quảng cáo, không cần tài khoản, và dữ liệu chỉ lưu trên máy.

- Dùng bộ 600 câu hỏi chính thức (Cục CSGT, 2025). Mỗi hạng có bộ câu, câu điểm liệt, cấu trúc đề và điểm đạt riêng.
- Có thi thử, ôn theo chủ đề, câu điểm liệt, câu sai, câu đã lưu, thư viện biển báo, tìm kiếm, mẹo ghi nhớ và hỏi đáp.
- Lời giải thích của cả 600 câu, phần mẹo và phần hỏi đáp đều là nội dung tự biên soạn.

## Chạy ứng dụng

Cần Flutter 3.47 trở lên.

```bash
cd app
flutter pub get
flutter run            # chọn máy ảo iOS/Android hoặc thiết bị
flutter test           # 92 test: đơn vị, nội dung, e2e, trợ năng
```

## Cấu trúc

| thư mục | nội dung |
| --- | --- |
| `app/` | mã nguồn Flutter; nội dung đã build nằm trong `app/assets/content/` |
| `content/source/` | các PDF chính thức dùng để dựng bộ đề |
| `content/explanations/` | lời giải thích tự viết cho 600 câu |
| `content/articles/` | mẹo, hỏi đáp và cách chia nhóm biển báo |
| `tool/content/` | script dựng `content.json`, hình ảnh và `articles.json`, có kiểm tra đối chiếu |
| `replica/` | tài liệu dự án: khảo sát, kiến trúc, thiết kế, kế hoạch test, lỗi, độ tương đồng |

## Dựng lại nội dung

```bash
python3 -m venv .venv && .venv/bin/pip install -r tool/content/requirements.txt
.venv/bin/python tool/content/build_content.py --require-all
```

Script sẽ báo lỗi và không ghi gì ra nếu có bất kỳ bước kiểm tra nào không đạt. Ví dụ: thiếu lời giải thích, hoặc một con số trong mẹo không khớp đáp án chính thức. Nguồn và giấy phép của nội dung xem trong `content/README.md`.

## Trước khi phát hành

- Đặt tên và nhận diện thương hiệu riêng (`/replica-brand`).
- Đưa trang chính sách quyền riêng tư lên mạng.
- Nhờ giáo viên dạy lái rà lại phần nội dung tự viết. Các câu cần xem trước nằm trong `content/README.md`.
