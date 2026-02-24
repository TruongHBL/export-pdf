# Prawn PDF Generator - 予約カルテ (Reservation Card)

## 📖 Giới thiệu

Prawn là thư viện Ruby thuần túy để tạo PDF bằng code programmatic. Thay vì dùng HTML/CSS, bạn "vẽ" PDF bằng các lệnh Ruby như `text`, `table`, `rectangle`, v.v.

**File demo**: `prawn_gem.rb`  
**Output**: `export_with_prawn.pdf`

## ✅ Ưu điểm

- ⚡ **Hiệu năng cao**: ~0.1-0.2 giây
- 🎯 **Kiểm soát tuyệt đối**: Từng pixel, từng border
- 🔧 **Pure Ruby**: Không cần external dependencies (wkhtmltopdf)
- 📦 **Nhẹ**: Không cần render engine
- 🔒 **Stable**: API ổn định, ít thay đổi

## ❌ Nhược điểm

- 📐 **Phức tạp**: Phải tính toán vị trí, kích thước thủ công
- 🐛 **Debug khó**: Phải chạy lại code để xem thay đổi
- 🎨 **Layout khó**: Không có flexbox, grid
- 👨‍💻 **Code nhiều**: Layout phức tạp = nhiều code
- 📝 **Learning curve**: Phải học API riêng

## 🚀 Cài đặt

### 1. Cài đặt gems

```bash
# Gemfile
gem 'prawn', '~> 2.4'
gem 'prawn-table', '~> 0.2'

# Install
bundle install
```

### 2. Cài đặt font tiếng Nhật

Prawn cần font path chính xác để hiển thị Unicode:

```bash
# Tạo thư mục fonts
mkdir -p ~/.fonts

# Download Noto Sans JP
cd ~/.fonts
wget https://github.com/google/fonts/raw/main/ofl/notosansjp/NotoSansJP-Regular.ttf

# Hoặc cài system-wide
# Ubuntu/Debian
sudo apt-get install fonts-noto-cjk

# macOS
brew tap homebrew/cask-fonts
brew install font-noto-sans-cjk-jp

# Fedora/RHEL
sudo dnf install google-noto-sans-cjk-fonts
```

### 3. Kiểm tra font

```ruby
font_path = File.expand_path('~/.fonts/NotoSansJP-Regular.ttf')
if File.exist?(font_path)
  puts "✅ Font OK: #{font_path}"
else
  puts "❌ Font missing!"
  puts "Tải từ: https://fonts.google.com/noto/specimen/Noto+Sans+JP"
end
```

## 🎯 Chạy demo

```bash
ruby prawn_gem.rb
```

Sẽ tạo file `export_with_prawn.pdf` (~45KB)

**Benchmark**: ~0.15 giây

## 📝 Cấu trúc code

### 1. Khởi tạo Document

```ruby
require 'prawn'

# Tạo PDF A4, landscape
pdf = Prawn::Document.new(
  page_size: 'A4',
  page_layout: :landscape,  # hoặc :portrait
  margin: [10, 10, 10, 10]  # [top, right, bottom, left] in points
)
```

### 2. Set font Unicode

```ruby
FONT_PATH = File.expand_path('~/.fonts/NotoSansJP-Regular.ttf')

pdf.font(FONT_PATH) do
  pdf.text '予約カルテ'  # OK
  pdf.text '株式会社'    # OK
end

# Hoặc set global
pdf.font(FONT_PATH)
pdf.text 'すべてのtextがUnicodeになる'
```

### 3. Vẽ text với định dạng

```ruby
# Text đơn giản
pdf.text 'Hello World', size: 14

# Text với nhiều options
pdf.text '予約カルテ', 
  size: 18,
  style: :bold,           # :bold, :italic, :bold_italic
  align: :center,         # :left, :center, :right
  color: '000000'         # Hex color

# Text tại vị trí cụ thể
pdf.text_box 'Content',
  at: [x, y],             # [left, top] in points
  width: 200,
  height: 50,
  align: :center,
  valign: :center,        # :top, :center, :bottom
  overflow: :shrink_to_fit
```

### 4. Vẽ hình chữ nhật và border

```ruby
# Chỉ vẽ viền (stroke)
pdf.stroke_rectangle([x, y], width, height)

# Tô màu nền (fill)
pdf.fill_color 'EEEEEE'
pdf.fill_rectangle([x, y], width, height)

# Cả viền và nền
pdf.fill_and_stroke_rectangle([x, y], width, height)

# Line với độ dày tùy chỉnh
pdf.line_width(2)
pdf.stroke_line([x1, y1], [x2, y2])

# Dashed line
pdf.dash(3, space: 2)  # 3pt line, 2pt space
pdf.stroke_line([x1, y1], [x2, y2])
pdf.undash  # Reset về solid
```

### 5. Bounding Box (container)

```ruby
# Tạo container tại vị trí x, y
pdf.bounding_box([x, y], width: w, height: h) do
  # Tất cả lệnh trong này relative to box
  pdf.text 'Header'
  pdf.move_down 10
  pdf.text 'Content'
end

# Nested boxes
pdf.bounding_box([0, pdf.cursor], width: 500, height: 300) do
  pdf.stroke_bounds  # Vẽ border quanh box
  
  pdf.bounding_box([10, pdf.cursor - 10], width: 480) do
    pdf.text 'Inner content'
  end
end
```

### 6. Cursor management

```ruby
# Lấy vị trí cursor hiện tại
y = pdf.cursor

# Di chuyển cursor
pdf.move_down 20    # Xuống 20pt
pdf.move_up 10      # Lên 10pt

# Di chuyển đến vị trí cụ thể
pdf.move_cursor_to 500

# Lưu và khôi phục vị trí
saved_y = pdf.cursor
pdf.text 'Some content'
pdf.move_cursor_to saved_y  # Quay lại
```

### 7. Table (prawn-table gem)

```ruby
require 'prawn/table'

data = [
  ['Header 1', 'Header 2', 'Header 3'],
  ['Row 1 Col 1', 'Row 1 Col 2', 'Row 1 Col 3'],
  ['Row 2 Col 1', 'Row 2 Col 2', 'Row 2 Col 3']
]

pdf.table(data, 
  position: :center,
  width: pdf.bounds.width,
  cell_style: {
    size: 9,
    padding: [4, 8],       # [top/bottom, left/right]
    borders: [:top, :bottom],  # chỉ border trên/dưới
    border_width: 1,
    border_color: '000000'
  }
) do
  # Style header row
  row(0).font_style = :bold
  row(0).background_color = 'CCCCCC'
  
  # Style specific column
  column(0).align = :center
  column(1).width = 200
  
  # Style specific cell
  cells[1, 2].background_color = 'FFFF00'
end
```

### 8. Helper function: mm to points

```ruby
# PDF dùng points (1 inch = 72 points)
# Để dùng millimeters:

def mm(x)
  x * 2.8346  # 1mm ≈ 2.8346 points
end

# Sử dụng
pdf.stroke_rectangle([mm(10), mm(20)], mm(50), mm(30))
```

## 🎨 Best Practices

### 1. Tạo module/class cho reusability

```ruby
class ReservationCardPDF
  def initialize(data)
    @data = data
    @pdf = Prawn::Document.new(
      page_size: 'A4',
      page_layout: :landscape,
      margin: 10
    )
    setup_font
  end
  
  def generate
    draw_header
    draw_info_sections
    draw_guest_table
    draw_notes
    @pdf.render
  end
  
  private
  
  def setup_font
    @pdf.font(FONT_PATH)
  end
  
  def draw_header
    @pdf.text '予約カルテ', size: 16, style: :bold
  end
  
  # ... other methods
end

# Usage
pdf = ReservationCardPDF.new(reservation_data)
File.write('output.pdf', pdf.generate)
```

### 2. Dùng constants cho layout values

```ruby
class PDFConfig
  PAGE_WIDTH = 842    # A4 landscape width in points
  PAGE_HEIGHT = 595   # A4 landscape height in points
  
  MARGIN = 10
  FONT_SIZE_NORMAL = 9
  FONT_SIZE_HEADER = 12
  
  COLOR_BORDER = '000000'
  COLOR_BG_HEADER = 'EEEEEE'
end
```

### 3. Extract drawing logic

```ruby
class PDFDrawer
  def initialize(pdf)
    @pdf = pdf
  end
  
  def draw_field_box(x, y, width, height, label, value)
    @pdf.stroke_rectangle([x, y], width, height)
    
    # Label
    @pdf.text_box label,
      at: [x + 5, y - 5],
      width: width - 10,
      size: 7
    
    # Value
    @pdf.text_box value,
      at: [x + 5, y - height/2],
      width: width - 10,
      size: 9,
      valign: :center
  end
end
```

### 4. Handle page breaks

```ruby
def draw_large_content
  data.each do |item|
    # Nếu không đủ chỗ, tạo trang mới
    if @pdf.cursor < 100
      @pdf.start_new_page
      draw_header  # Vẽ lại header
    end
    
    draw_item(item)
    @pdf.move_down 20
  end
end
```

## 💡 Tips & Tricks

### 1. Debug layout với grid

```ruby
# Hiển thị grid để debug vị trí
pdf.stroke_axis

# Vẽ bounds (margins)
pdf.stroke_bounds
```

### 2. Reuse styles với inline_format

```ruby
pdf.text "<b>Bold</b> and <i>italic</i> text", 
  inline_format: true

pdf.text "Color: <color rgb='ff0000'>Red</color>",
  inline_format: true
```

### 3. Vertical text (rotate)

```ruby
pdf.rotate(90, origin: [x, y]) do
  pdf.text 'Vertical text'
end
```

### 4. Image support

```ruby
# Thêm ảnh
pdf.image 'logo.png',
  at: [x, y],
  width: 100,
  height: 50

# Hoặc fit vào box
pdf.image 'photo.jpg',
  at: [x, y],
  fit: [width, height]
```

### 5. Multiple pages

```ruby
# Tạo page đầu
pdf.text 'Page 1'

# Thêm page mới
pdf.start_new_page

# Page 2
pdf.text 'Page 2'

# Page với layout khác
pdf.start_new_page(layout: :portrait)
```

## 🔧 Rails Integration

### Controller

```ruby
class ReservationsController < ApplicationController
  def show
    @reservation = Reservation.find(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf_generator = ReservationCardPDF.new(@reservation)
        send_data pdf_generator.generate,
          filename: "reservation_#{@reservation.id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'  # 'attachment' to force download
      end
    end
  end
end
```

### Service Object

```ruby
# app/services/reservation_card_pdf.rb
class ReservationCardPDF
  include Prawn::View
  
  def initialize(reservation)
    @reservation = reservation
  end
  
  def document
    @document ||= Prawn::Document.new(
      page_size: 'A4',
      page_layout: :landscape
    )
  end
  
  def generate
    setup_font
    draw_content
    render
  end
  
  private
  
  def setup_font
    font(Rails.root.join('app/assets/fonts/NotoSansJP-Regular.ttf'))
  end
  
  def draw_content
    text "予約No: #{@reservation.number}"
    # ...
  end
end
```

### Background Job (Sidekiq)

```ruby
class GenerateReservationPDFJob < ApplicationJob
  queue_as :default
  
  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    pdf = ReservationCardPDF.new(reservation).generate
    
    # Upload to S3
    s3_key = "reservations/#{reservation.id}/card.pdf"
    S3_BUCKET.put_object(
      key: s3_key,
      body: pdf,
      content_type: 'application/pdf'
    )
    
    # Update record
    reservation.update(pdf_url: s3_key)
  end
end
```

## 🐛 Troubleshooting

### Font không hiển thị Unicode

```ruby
# ❌ Sai
pdf.text '日本語'  # Hiển thị ???

# ✅ Đúng
pdf.font('path/to/NotoSansJP.ttf') do
  pdf.text '日本語'
end
```

### Text bị crop

```ruby
# ❌ Text_box không tự xuống dòng mặc định
pdf.text_box 'Very long text...', at: [0, 500], width: 100

# ✅ Cho phép xuống dòng
pdf.text_box 'Very long text...', 
  at: [0, 500], 
  width: 100,
  overflow: :shrink_to_fit  # hoặc :expand
```

### Cursor không đúng

```ruby
# ❌ Vẽ rectangle không di chuyển cursor
pdf.stroke_rectangle([0, pdf.cursor], 100, 50)
pdf.text 'Text'  # Sẽ đè lên rectangle!

# ✅ Di chuyển cursor thủ công
pdf.stroke_rectangle([0, pdf.cursor], 100, 50)
pdf.move_down 60  # 50 (height) + 10 (spacing)
pdf.text 'Text'
```

### File PDF quá lớn

```ruby
# Font embedding làm file lớn
# Giải pháp: Sử dụng font nhẹ hơn hoặc compress

# Compress images trước khi thêm
require 'mini_magick'

image = MiniMagick::Image.open('large.jpg')
image.resize '800x600'
image.quality 85
image.write 'compressed.jpg'

pdf.image 'compressed.jpg', width: 200
```

## 📊 Performance Tips

### 1. Reuse font objects

```ruby
# ❌ Chậm - load font nhiều lần
1000.times do
  pdf.font('NotoSans.ttf') { pdf.text 'Text' }
end

# ✅ Nhanh - load 1 lần
pdf.font('NotoSans.ttf')
1000.times { pdf.text 'Text' }
```

### 2. Batch rendering

```ruby
# Generate nhiều PDFs
reservations.find_in_batches(batch_size: 100) do |batch|
  batch.each do |reservation|
    GenerateReservationPDFJob.perform_later(reservation.id)
  end
end
```

### 3. Cache complex calculations

```ruby
class ReservationCardPDF
  def initialize(reservation)
    @reservation = reservation
    @layout_cache = calculate_layout  # Tính 1 lần
  end
  
  def calculate_layout
    {
      col_widths: [100, 200, 150],
      row_height: 20,
      # ...
    }
  end
end
```

## 📚 Tài liệu tham khảo

- [Prawn Manual PDF](https://prawnpdf.org/manual.pdf) - Đọc bắt buộc!
- [Prawn GitHub](https://github.com/prawnpdf/prawn)
- [Prawn Table](https://github.com/prawnpdf/prawn-table)
- [Prawn API Docs](https://www.rubydoc.info/gems/prawn)
