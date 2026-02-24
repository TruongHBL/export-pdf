# WickedPDF Generator - 予約カルテ (Reservation Card)

## 📖 Giới thiệu

WickedPDF là wrapper cho `wkhtmltopdf` - tool convert HTML → PDF. Bạn viết HTML/CSS như làm web, rồi render thành PDF. Rất phù hợp cho team có designer giỏi HTML/CSS.

**File demo**: `wicked_gem.rb`  
**Output**: `export_with_wicked.pdf`

## ✅ Ưu điểm

- 🎨 **Dễ làm layout**: Dùng HTML/CSS quen thuộc
- 👀 **Preview được**: Debug bằng browser trước khi export
- 🔄 **Responsive**: Media queries cho in ấn
- 📱 **Reuse template**: Dùng lại email/web template
- 👨‍🎨 **Designer friendly**: Không cần biết Ruby
- 🛠️ **CSS frameworks**: Bootstrap, Tailwind OK
- 🧩 **Component-based**: Dễ chia nhỏ thành partials

## ❌ Nhược điểm

- 🐌 **Chậm hơn**: ~0.5-1 giây (vs 0.1s của Prawn)
- 📦 **External dependency**: Cần cài `wkhtmltopdf`
- 💾 **Memory intensive**: Render engine tốn RAM
- 🐳 **Docker phức tạp**: Cần cài package trong container
- ⚠️ **wkhtmltopdf deprecated**: Dự án không được maintain nhiều
- 🔧 **Server requirements**: Không chạy được trên shared hosting

## 🚀 Cài đặt

### 1. Cài đặt gems

```bash
# Gemfile
gem 'wicked_pdf', '~> 2.8'
gem 'wkhtmltopdf-binary', '~> 0.12'  # Bao gồm binary

# Install
bundle install
```

### 2. Cài đặt wkhtmltopdf (tùy chọn)

Nếu không dùng `wkhtmltopdf-binary` gem:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install wkhtmltopdf

# macOS
brew install wkhtmltopdf

# Fedora/RHEL
sudo dnf install wkhtmltopdf

# Download binary trực tiếp
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
```

### 3. Kiểm tra cài đặt

```bash
# Kiểm tra wkhtmltopdf
which wkhtmltopdf
# => /usr/local/bin/wkhtmltopdf

# Test convert
wkhtmltopdf https://google.com test.pdf
# => Tạo file test.pdf
```

### 4. Rails configuration (nếu dùng Rails)

```ruby
# config/initializers/wicked_pdf.rb
WickedPdf.config = {
  # Tự động tìm binary
  # exe_path: '/usr/local/bin/wkhtmltopdf',
  
  # Enable local file access (cho CSS, images)
  enable_local_file_access: true,
  
  # Thêm options mặc định
  # margin: { top: 0, bottom: 0, left: 0, right: 0 }
}
```

## 🎯 Chạy demo

```bash
ruby wicked_gem.rb
```

Sẽ tạo file `export_with_wicked.pdf` (~28KB)

**Benchmark**: ~0.82 giây

## 📝 Cấu trúc code

### 1. Basic usage (Ruby script)

```ruby
require 'wicked_pdf'

html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      body { font-family: 'Noto Sans JP', sans-serif; }
      .title { font-size: 18px; font-weight: bold; }
    </style>
  </head>
  <body>
    <div class="title">予約カルテ</div>
  </body>
  </html>
HTML

wicked = WickedPdf.new
pdf = wicked.pdf_from_string(html)

File.open('output.pdf', 'wb') { |f| f << pdf }
```

### 2. HTML với inline CSS

```ruby
html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      
      body {
        font-family: 'Noto Sans JP', sans-serif;
        font-size: 9pt;
        line-height: 1.4;
      }
      
      .page {
        width: 297mm;    /* A4 landscape */
        height: 210mm;
        padding: 5mm;
      }
      
      .header {
        border-bottom: 2px solid black;
        padding-bottom: 5mm;
        margin-bottom: 5mm;
      }
      
      .field {
        border: 1px solid black;
        padding: 2mm;
        display: inline-block;
      }
      
      .field-label {
        font-size: 7pt;
        color: #666;
      }
      
      .field-value {
        font-size: 9pt;
        font-weight: bold;
      }
      
      table {
        width: 100%;
        border-collapse: collapse;
      }
      
      td, th {
        border: 1px solid black;
        padding: 2mm;
        text-align: left;
      }
      
      th {
        background-color: #f0f0f0;
        font-weight: bold;
      }
      
      /* Print-specific CSS */
      @media print {
        .no-print { display: none; }
        .page-break { page-break-after: always; }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <div class="header">
        <h1>予約カルテ</h1>
      </div>
      
      <div class="field">
        <div class="field-label">予約No</div>
        <div class="field-value">180117-001</div>
      </div>
      
      <table>
        <thead>
          <tr>
            <th>項目</th>
            <th>内容</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>顧客名</td>
            <td>株式会社ケイズ</td>
          </tr>
        </tbody>
      </table>
    </div>
  </body>
  </html>
HTML
```

### 3. Với external CSS file

```ruby
html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="file:///path/to/styles.css">
  </head>
  <body>
    <h1>予約カルテ</h1>
  </body>
  </html>
HTML

# Cần enable local file access
wicked = WickedPdf.new(enable_local_file_access: true)
pdf = wicked.pdf_from_string(html)
```

### 4. Với template engine (ERB)

```ruby
require 'erb'

template = <<~ERB
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>
      .title { font-size: 18px; }
    </style>
  </head>
  <body>
    <h1>予約カルテ No. <%= reservation_no %></h1>
    
    <table>
      <% items.each do |item| %>
        <tr>
          <td><%= item[:label] %></td>
          <td><%= item[:value] %></td>
        </tr>
      <% end %>
    </table>
  </body>
  </html>
ERB

# Data
reservation_no = '180117-001'
items = [
  { label: '顧客名', value: '株式会社ケイズ' },
  { label: '利用日', value: '18/01/17 (水)' }
]

# Render
html = ERB.new(template).result(binding)
pdf = WickedPdf.new.pdf_from_string(html)
```

### 5. Options cho PDF

```ruby
wicked = WickedPdf.new

pdf = wicked.pdf_from_string(html,
  # Page size
  page_size: 'A4',
  orientation: 'Landscape',  # hoặc 'Portrait'
  
  # Margins (mm)
  margin: {
    top: 10,
    bottom: 10,
    left: 10,
    right: 10
  },
  
  # DPI
  dpi: 96,  # hoặc 300 cho chất lượng cao
  
  # Encoding
  encoding: 'UTF-8',
  
  # JavaScript
  enable_javascript: false,
  javascript_delay: 200,  # ms
  
  # Disable smart shrinking
  disable_smart_shrinking: true,
  
  # Background
  print_media_type: true,
  background: true,
  
  # Header/Footer
  header: {
    center: '予約カルテ',
    font_size: 10
  },
  footer: {
    right: '[page]/[topage]',
    font_size: 8
  }
)
```

## 🎨 CSS Best Practices

### 1. Page setup

```css
/* A4 Landscape */
@page {
  size: A4 landscape;
  margin: 10mm;
}

/* A4 Portrait */
@page {
  size: A4 portrait;
  margin: 15mm;
}

/* Custom size */
@page {
  size: 297mm 210mm;  /* width height */
  margin: 5mm;
}

body {
  margin: 0;
  padding: 0;
}
```

### 2. Page breaks

```css
/* Force page break sau element */
.page-break {
  page-break-after: always;
}

/* Không break inside element */
.no-break {
  page-break-inside: avoid;
}

/* Break trước element */
.section {
  page-break-before: always;
}

/* Ví dụ: mỗi section 1 trang */
.section {
  min-height: 100vh;
  page-break-after: always;
}
```

### 3. Font loading

```css
/* Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap');

body {
  font-family: 'Noto Sans JP', sans-serif;
}

/* Local fonts */
@font-face {
  font-family: 'CustomFont';
  src: url('file:///path/to/font.ttf') format('truetype');
}

body {
  font-family: 'CustomFont', sans-serif;
}
```

### 4. Table styling

```css
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 9pt;
}

/* Giữ header trên mỗi trang */
thead {
  display: table-header-group;
}

tfoot {
  display: table-footer-group;
}

th, td {
  border: 1px solid #000;
  padding: 4mm 2mm;
  text-align: left;
}

th {
  background-color: #f0f0f0;
  font-weight: bold;
}

/* Zebra striping */
tbody tr:nth-child(even) {
  background-color: #fafafa;
}

/* Không break row */
tr {
  page-break-inside: avoid;
}
```

### 5. Layout helpers

```css
/* Flexbox layout */
.row {
  display: flex;
  gap: 2mm;
}

.col {
  flex: 1;
}

.col-2 {
  flex: 2;
}

/* Grid layout */
.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2mm;
}

/* Field box pattern */
.field {
  border: 1px solid #000;
  padding: 2mm;
  position: relative;
}

.field-label {
  font-size: 7pt;
  color: #666;
  margin-bottom: 1mm;
}

.field-value {
  font-size: 9pt;
  font-weight: bold;
}
```

## 💡 Tips & Tricks

### 1. Debug HTML trước khi export

```ruby
# Save HTML to file để xem trong browser
html = generate_html(data)
File.write('debug.html', html)

# Mở trong browser để debug CSS
system('open debug.html')  # macOS
system('xdg-open debug.html')  # Linux

# Sau khi OK, mới export PDF
pdf = WickedPdf.new.pdf_from_string(html)
```

### 2. Reuse CSS từ file riêng

```ruby
# styles.css
css = File.read('styles.css')

html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <style>#{css}</style>
  </head>
  <body>
    <!-- content -->
  </body>
  </html>
HTML
```

### 3. Header/Footer với HTML

```ruby
header_html = <<~HTML
  <div style="text-align: center; font-size: 10pt;">
    予約カルテ
  </div>
HTML

footer_html = <<~HTML
  <div style="text-align: right; font-size: 8pt;">
    Page <span class="page"></span> of <span class="topage"></span>
  </div>
HTML

pdf = wicked.pdf_from_string(html,
  header: { content: header_html },
  footer: { content: footer_html }
)
```

### 4. Images trong PDF

```ruby
html = <<~HTML
  <img src="file:///absolute/path/to/image.png" width="100">
  
  <!-- Hoặc base64 -->
  <img src="data:image/png;base64,iVBORw0KG..." width="100">
  
  <!-- URL (cần internet) -->
  <img src="https://example.com/logo.png" width="100">
HTML
```

### 5. Conditional content cho PDF

```css
/* CSS */
.pdf-only { display: none; }

@media print {
  .pdf-only { display: block; }
  .web-only { display: none; }
}
```

```html
<!-- HTML -->
<div class="pdf-only">
  Nội dung này chỉ hiện trong PDF
</div>

<div class="web-only">
  Nội dung này chỉ hiện trên web
</div>
```

## 🔧 Rails Integration

### 1. Controller

```ruby
class ReservationsController < ApplicationController
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "reservation_#{@reservation.id}",
               template: 'reservations/show.pdf.erb',
               layout: 'pdf.html.erb',
               page_size: 'A4',
               orientation: 'Landscape',
               margin: { top: 10, bottom: 10, left: 10, right: 10 }
      end
    end
  end
end
```

### 2. PDF Layout

```erb
<!-- app/views/layouts/pdf.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    <%= Rails.application.assets['pdf.css'].to_s %>
  </style>
</head>
<body>
  <%= yield %>
</body>
</html>
```

### 3. PDF View Template

```erb
<!-- app/views/reservations/show.pdf.erb -->
<div class="page">
  <div class="header">
    <h1>予約カルテ</h1>
    <div class="meta">
      印刷：<%= Time.current.strftime('%Y/%m/%d %H:%M') %>
    </div>
  </div>
  
  <div class="info-section">
    <div class="field">
      <div class="field-label">予約No</div>
      <div class="field-value"><%= @reservation.number %></div>
    </div>
    
    <div class="field">
      <div class="field-label">顧客名</div>
      <div class="field-value"><%= @reservation.customer_name %></div>
    </div>
  </div>
  
  <table class="guest-table">
    <thead>
      <tr>
        <th>氏名</th>
        <th>カナ</th>
        <th>性別</th>
      </tr>
    </thead>
    <tbody>
      <% @reservation.guests.each do |guest| %>
        <tr>
          <td><%= guest.name %></td>
          <td><%= guest.kana %></td>
          <td><%= guest.gender %></td>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

### 4. CSS Asset

```css
/* app/assets/stylesheets/pdf.css */
@page {
  size: A4 landscape;
  margin: 10mm;
}

body {
  font-family: 'Noto Sans JP', sans-serif;
  font-size: 9pt;
  margin: 0;
  padding: 0;
}

.page {
  width: 100%;
}

.header {
  border-bottom: 2px solid black;
  padding-bottom: 5mm;
  margin-bottom: 5mm;
}

/* ... other styles ... */
```

### 5. Helper Methods

```ruby
# app/helpers/pdf_helper.rb
module PdfHelper
  def pdf_field(label, value, options = {})
    content_tag(:div, class: 'field') do
      concat content_tag(:div, label, class: 'field-label')
      concat content_tag(:div, value, class: 'field-value')
    end
  end
  
  def pdf_checkbox(checked)
    checked ? '☑' : '☐'
  end
end
```

Usage in view:
```erb
<%= pdf_field('予約No', @reservation.number) %>
<%= pdf_checkbox(@reservation.confirmed?) %> 確認済み
```

### 6. Background Job

```ruby
# app/jobs/generate_reservation_pdf_job.rb
class GenerateReservationPDFJob < ApplicationJob
  queue_as :default
  
  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    
    # Render PDF
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string(
        template: 'reservations/show.pdf.erb',
        layout: 'pdf.html.erb',
        locals: { reservation: reservation }
      ),
      page_size: 'A4',
      orientation: 'Landscape'
    )
    
    # Upload to S3
    s3_key = "reservations/#{reservation.id}/card.pdf"
    S3_BUCKET.put_object(
      key: s3_key,
      body: pdf,
      content_type: 'application/pdf'
    )
    
    reservation.update(pdf_url: s3_key)
  end
  
  private
  
  def render_to_string(*args)
    ApplicationController.new.render_to_string(*args)
  end
end
```

## 🐛 Troubleshooting

### wkhtmltopdf command failed

```bash
# Kiểm tra binary tồn tại
which wkhtmltopdf

# Test chạy trực tiếp
wkhtmltopdf --version

# Nếu lỗi "cannot open shared object file"
# Ubuntu/Debian
sudo apt-get install libxrender1 libfontconfig1 libxtst6 libxi6
```

### Font không hiển thị

```ruby
# Dùng Google Fonts trong CSS
html = <<~HTML
  <link rel="stylesheet" 
        href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP&display=swap">
HTML

# Hoặc enable local file access
WickedPdf.config = {
  enable_local_file_access: true
}
```

### CSS không apply

```ruby
# ❌ External CSS không load
<link rel="stylesheet" href="styles.css">

# ✅ Inline CSS hoặc absolute path
<style>
  /* CSS here */
</style>

# Hoặc
<link rel="stylesheet" href="file:///absolute/path/to/styles.css">
```

### Page breaks không đúng

```css
/* Đảm bảo element không bị break */
table, .section {
  page-break-inside: avoid;
}

/* Force break */
.new-page {
  page-break-before: always;
}
```

### Memory issues với nhiều PDFs

```ruby
# Tạo từng PDF riêng, không cache
reservations.find_each do |reservation|
  pdf = generate_pdf(reservation)
  save_pdf(pdf, reservation.id)
  pdf = nil  # Free memory
  GC.start   # Force garbage collection
end
```

## 📊 Performance Optimization

### 1. Reuse CSS

```ruby
# Cache CSS content
CSS_CONTENT = File.read('styles.css').freeze

def generate_html(data)
  <<~HTML
    <style>#{CSS_CONTENT}</style>
    <!-- content -->
  HTML
end
```

### 2. Disable JavaScript

```ruby
# JS làm chậm đi nhiều
pdf = wicked.pdf_from_string(html,
  enable_javascript: false  # Nhanh hơn nhiều
)
```

### 3. Lower DPI cho preview

```ruby
# Preview với DPI thấp
preview_pdf = wicked.pdf_from_string(html, dpi: 96)

# Export final với DPI cao
final_pdf = wicked.pdf_from_string(html, dpi: 300)
```

### 4. Parallel processing

```ruby
require 'parallel'

Parallel.each(reservations, in_processes: 4) do |reservation|
  pdf = generate_pdf(reservation)
  save_pdf(pdf, reservation.id)
end
```

## 📚 Tài liệu tham khảo

- [WickedPDF GitHub](https://github.com/mileszs/wicked_pdf)
- [wkhtmltopdf Documentation](https://wkhtmltopdf.org/usage/wkhtmltopdf.txt)
- [CSS Paged Media](https://www.w3.org/TR/css-page-3/)
- [Print CSS Guide](https://www.smashingmagazine.com/2015/01/designing-for-print-with-css/)
