# PDF Generator - So sánh Prawn vs WickedPDF

Dự án demo tạo PDF "予約カルテ" (Reservation Card) bằng 2 cách:
- **Prawn**: Vẽ PDF bằng Ruby code (programmatic)
- **WickedPDF**: Render PDF từ HTML/CSS (declarative)

## 📋 Tổng quan

| Tiêu chí | Prawn | WickedPDF |
|----------|-------|-----------|
| **Cách tiếp cận** | Programmatic (code vẽ trực tiếp) | HTML/CSS → PDF |
| **Độ phức tạp** | Cao (phải tính toán vị trí, kích thước) | Thấp (như làm web) |
| **Hiệu năng** | Nhanh hơn (~0.1s) | Chậm hơn (~0.5-1s) |
| **Font Unicode** | Cần cấu hình font path | Tự động (qua CSS) |
| **Layout phức tạp** | Khó (nhiều code) | Dễ (flex, grid, table) |
| **Responsive** | Không | Có (media query) |
| **Debug** | Khó (phải chạy lại) | Dễ (xem HTML trước) |
| **Kích thước file** | Lớn (embed font) | Nhỏ hơn |

## 🚀 Cài đặt

### 1. Cài đặt Ruby gems

```bash
bundle install
```

Nếu chưa có bundler:
```bash
gem install bundler
```

### 2. Cài đặt font tiếng Nhật (cho Prawn)

```bash
# Tải Noto Sans JP
mkdir -p ~/.fonts
cd ~/.fonts
wget https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP-Regular.ttf

# Ubuntu/Debian (tùy chọn)
sudo apt-get install fonts-noto-cjk

# Fedora/RHEL
sudo dnf install google-noto-sans-cjk-fonts

# Arch Linux
sudo pacman -S noto-fonts-cjk
```

### 3. Cài đặt wkhtmltopdf (cho WickedPDF)

WickedPDF cần `wkhtmltopdf` để convert HTML → PDF:

```bash
# Ubuntu/Debian
sudo apt-get install wkhtmltopdf

# macOS
brew install wkhtmltopdf

# Hoặc dùng gem (đã bao gồm binary)
gem install wkhtmltopdf-binary
```

## 📦 Cấu trúc project

```
export_pdf/
├── Gemfile                    # Dependencies
├── Gemfile.lock
├── prawn_gem.rb              # ✏️ Generator dùng Prawn
├── wicked_gem.rb             # 🌐 Generator dùng WickedPDF
├── Template_PDF.pdf          # 📄 File template gốc để tham khảo
├── export_with_prawn.pdf     # ✅ Output từ Prawn
├── export_with_wicked.pdf    # ✅ Output từ WickedPDF
└── README.md
```

## 🎯 Chạy demo

### Demo với Prawn

```bash
ruby prawn_gem.rb
```

Output: `export_with_prawn.pdf`

**Benchmark**: ~0.1 - 0.2 giây

### Demo với WickedPDF

```bash
ruby wicked_gem.rb
```

Output: `export_with_wicked.pdf`

**Benchmark**: ~0.5 - 1 giây (chậm hơn vì phải render HTML)

## 📝 Tính năng của template "予約カルテ"

Cả 2 cách đều tạo form "Reservation Card" tiếng Nhật với:

1. **Header**: Thông tin in, số thẻ, kana search
2. **Section 1**: Thông tin đặt phòng (予約No, 区分, 顧客No, etc.)
3. **Section 2**: Thông tin sử dụng (利用日, 宿泊, 受付日時, etc.)
4. **Section 3**: Thông tin khách hàng (お客様名, ふりがな, 看板, etc.)
5. **Section 4**: Thông tin đặt phòng chi tiết (予約Status, 有効期限, 代表単価, etc.)
6. **Section 5**: Thông tin liên lạc (電話, FAX, 住所)
7. **Section 6**: Bảng danh sách khách (表, 氏名, カナ, 続柄, etc.)
8. **Section 7**: Ghi chú (備考)

## 💡 Khi nào dùng Prawn?

✅ **Nên dùng khi**:
- Cần **hiệu năng cao**, tạo PDF nhanh
- Layout **đơn giản, cố định** (invoice, receipt, label)
- Cần **kiểm soát tuyệt đối** từng pixel
- Tạo PDF từ **data trực tiếp** (không cần template)
- Tích hợp vào **background job** (tạo hàng nghìn PDF)

❌ **Không nên dùng khi**:
- Layout **phức tạp, responsive**
- Có nhiều **designer** không biết Ruby
- Cần **preview** trước khi xuất PDF
- Thường xuyên **thay đổi design**

### Ví dụ code Prawn cơ bản

```ruby
require 'prawn'

pdf = Prawn::Document.new(page_size: 'A4')

# Set font hỗ trợ Unicode
pdf.font('~/.fonts/NotoSansJP-Regular.ttf')

# Vẽ text
pdf.text '予約カルテ', size: 18, style: :bold

# Vẽ table
pdf.table([
  ['予約No', '180117-001'],
  ['顧客名', '株式会社ケイズ']
], width: 500)

# Lưu file
pdf.render_file('output.pdf')
```

## 🌐 Khi nào dùng WickedPDF?

✅ **Nên dùng khi**:
- Layout **phức tạp, responsive**
- Team có **designer** giỏi HTML/CSS
- Cần **preview** HTML trước (debug dễ)
- Có sẵn **HTML template** (email, web page)
- Layout thay đổi **thường xuyên**
- Sử dụng **CSS framework** (Bootstrap, Tailwind)

❌ **Không nên dùng khi**:
- Cần **hiệu năng cao** (realtime export)
- Server không cài được `wkhtmltopdf`
- Tạo **hàng nghìn PDF** cùng lúc (memory intensive)

### Ví dụ code WickedPDF cơ bản

```ruby
require 'wicked_pdf'

html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      body { font-family: 'Noto Sans JP', sans-serif; }
      .header { font-size: 18px; font-weight: bold; }
      table { border-collapse: collapse; width: 100%; }
      td { border: 1px solid black; padding: 5px; }
    </style>
  </head>
  <body>
    <div class="header">予約カルテ</div>
    <table>
      <tr><td>予約No</td><td>180117-001</td></tr>
      <tr><td>顧客名</td><td>株式会社ケイズ</td></tr>
    </table>
  </body>
  </html>
HTML

wicked = WickedPdf.new
pdf = wicked.pdf_from_string(html)
File.open('output.pdf', 'wb') { |f| f << pdf }
```

## 🔧 Tích hợp với Rails

### Prawn trong Rails Controller

```ruby
class InvoicesController < ApplicationController
  def show
    @invoice = Invoice.find(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePrawnGenerator.new(@invoice).render
        send_data pdf, 
          filename: "invoice_#{@invoice.id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'  # hiển thị trong browser
      end
    end
  end
end
```

### WickedPDF trong Rails Controller

```ruby
class InvoicesController < ApplicationController
  def show
    @invoice = Invoice.find(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "invoice_#{@invoice.id}",
               template: 'invoices/show.pdf.erb',
               layout: 'pdf.html.erb'
      end
    end
  end
end
```

View template `invoices/show.pdf.erb`:
```erb
<div class="invoice">
  <h1>Invoice #<%= @invoice.number %></h1>
  <table>
    <% @invoice.items.each do |item| %>
      <tr>
        <td><%= item.name %></td>
        <td><%= number_to_currency(item.price) %></td>
      </tr>
    <% end %>
  </table>
</div>
```

## 🎨 Tips & Tricks

### Prawn

#### 1. Sử dụng cursor để quản lý vị trí

```ruby
pdf.text "Header"
current_y = pdf.cursor  # Lưu vị trí hiện tại
pdf.move_down 20        # Di chuyển xuống 20pt
```

#### 2. Vẽ border và background

```ruby
pdf.stroke_rectangle([x, y], width, height)
pdf.fill_color 'EEEEEE'
pdf.fill_rectangle([x, y], width, height)
```

#### 3. Sử dụng bounding box

```ruby
pdf.bounding_box([x, y], width: w, height: h) do
  pdf.text "Content trong box"
end
```

### WickedPDF

#### 1. Tối ưu font loading

```html
<style>
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP&display=swap');
</style>
```

#### 2. Page break control

```html
<style>
  .page-break { page-break-after: always; }
  .no-break { page-break-inside: avoid; }
</style>
```

#### 3. Header/Footer cho tất cả trang

```ruby
render pdf: "document",
       header: { html: { template: 'layouts/pdf_header.html' } },
       footer: { html: { template: 'layouts/pdf_footer.html' } }
```

## 📊 Benchmark chi tiết

Test trên máy Ubuntu 22.04, Ruby 3.1.2:

```
Prawn Generation Time: 0.15 seconds
WickedPDF Generation Time: 0.82 seconds

Prawn file size: 45KB
WickedPDF file size: 28KB
```

**Kết luận**: Prawn nhanh hơn ~5x, nhưng file lớn hơn (do embed font).

## 📚 Tài liệu tham khảo

### Prawn
- [Prawn Manual](https://prawnpdf.org/manual.pdf) - Tài liệu chính thức
- [Prawn GitHub](https://github.com/prawnpdf/prawn)
- [Prawn Table](https://github.com/prawnpdf/prawn-table)

### WickedPDF
- [WickedPDF GitHub](https://github.com/mileszs/wicked_pdf)
- [wkhtmltopdf Documentation](https://wkhtmltopdf.org/usage/wkhtmltopdf.txt)
- [CSS for Print Media](https://www.smashingmagazine.com/2015/01/designing-for-print-with-css/)

### Fonts
- [Noto Fonts](https://fonts.google.com/noto) - Google's free Unicode fonts
- [Font Awesome](https://fontawesome.com/) - Icons cho PDF

## 🐛 Troubleshooting

### Prawn: Font không hiển thị tiếng Nhật

```ruby
# Kiểm tra font path
font_path = File.expand_path('~/.fonts/NotoSansJP-Regular.ttf')
puts File.exist?(font_path) ? "Font OK" : "Font missing"

# Thử dùng system font
pdf.font('/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc')
```

### WickedPDF: Command failed

```bash
# Kiểm tra wkhtmltopdf có cài chưa
which wkhtmltopdf

# Test trực tiếp
wkhtmltopdf http://google.com test.pdf
```

### WickedPDF: Không render được font

```ruby
# Thêm vào config/initializers/wicked_pdf.rb
WickedPdf.config = {
  exe_path: '/usr/local/bin/wkhtmltopdf',
  enable_local_file_access: true
}
```

## 🤝 Contributing

Nếu bạn có cải tiến hoặc phát hiện bug, hãy:
1. Fork repo này
2. Tạo branch mới: `git checkout -b feature/improvement`
3. Commit changes: `git commit -am 'Add some feature'`
4. Push to branch: `git push origin feature/improvement`
5. Tạo Pull Request

## 📄 License

MIT License - Free to use for personal and commercial projects.

---

**Tác giả**: TruongHBL  
**Ngày cập nhật**: 24/02/2026  
**Version**: 2.0
