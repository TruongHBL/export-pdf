#!/usr/bin/env ruby
# =============================================================
# 予約カルテ - WickedPDF Version (CLEAN & READABLE)
# Sử dụng HTML/CSS - DỄ ĐỌC & DỄ SỬA hơn Prawn nhiều!
#
# Cài đặt: gem install wicked_pdf wkhtmltopdf-binary
# Chạy: ruby wicked_generator_v2.rb
# =============================================================

require 'wicked_pdf'
require 'benchmark'

class YoyakuKarteGenerator
  def initialize
    @wicked = WickedPdf.new
  end

  def generate
    # Data mẫu giống template
    data = {
      print_date: '印刷：2018/01/16 17:55',
      card_no: '001',
      kana: 'ケ',
      yoyaku_no: '180117-001',
      yoyaku_kubun: '宿泊',
      kokyaku_no: '23',
      kokyaku_name: '株式会社ケイズ',
      riyo_date: '18/01/17 (水)',
      haku: '1/1',
      uketsuke: '18/01/17 14:10 KEIS',
      eigyo_tanto: '',
      kyaku_name: '株式会社ケイズ',
      kyaku_kana: 'ケイズ',
      kanban: '株式会社ケイズ新年会',
      kanji: '',
      kikaku: '',
      course: '',
      yoyaku_status: '本予約',
      yuko_kigen: '',
      daihyo_tanka: 'F18,000',
      riyo_mokuteki: '',
      shiharai: '',
      sessaku: '',
      nyukon: '',
      shuppatsu: '',
      shokuji: '朝食',
      tel: '0859348902',
      fax: '0859348912',
      toujitsu: '',
      yokujitsu: '',
      kokyaku_addr: '〒683-0853　鳥取県米子市両三柳2864-16',
      sofu_addr: '',
      yakushoku: '',
      namae: '',
      gyosha_addr: '〒683-0043　鳥取県米子市末広町181 第一Tビル',
      shokaisha: '',
      gyosha: '㈱JTB中国四国 米子支店',
      tanto: '',
      tel_gyosha: '',
      annaijo: '',
      eigyosho: '',
      chiku: '鳥取県'
    }

    html = generate_html(data)

    elapsed_time = Benchmark.realtime do
      pdf = @wicked.pdf_from_string(
        html,
        page_size: 'A4',
        margin: { top: 6, bottom: 6, left: 6, right: 6 },
        encoding: 'UTF-8',
        dpi: 300
      )

      File.open('export_with_wicked.pdf', 'wb') do |file|
        file << pdf
      end
    end

    file_size = File.size('export_with_wicked.pdf') / 1024.0 # KB

    puts '✅ Đã tạo file: export_with_wicked.pdf'
    puts "⏱️  Generation time: #{(elapsed_time * 1000).round(2)} ms"
    puts "📦 File size: #{file_size.round(2)} KB"
    puts '🚀 Speed: WickedPDF (HTML→PDF)'
  end

  private

  def generate_html(d)
    # Helper để tạo cell với border style tùy chỉnh
    cell = lambda do |content, opts = {}|
      style = []
      style << "width: #{opts[:w]}mm" if opts[:w]
      style << 'border-right: 1px dotted #888' if opts[:dr]
      style << 'border-bottom: 1px dotted #888' if opts[:db]
      style << 'text-align: center' if opts[:center]
      style << 'font-weight: bold' if opts[:bold]
      style << 'background: #DDDDDD' if opts[:gray]
      style << "font-size: #{opts[:fs]}pt" if opts[:fs]

      classes = []
      classes << (opts[:gray] ? 'hdr' : 'cell')
      classes << 'rowspan2' if opts[:rs2]

      tag = opts[:th] ? 'th' : 'td'
      attrs = []
      attrs << "class='#{classes.join(' ')}'"
      attrs << "style='#{style.join('; ')}'" unless style.empty?
      attrs << "colspan='#{opts[:cs]}'" if opts[:cs]
      attrs << "rowspan='#{opts[:rs]}'" if opts[:rs]

      "<#{tag} #{attrs.join(' ')}>#{content}</#{tag}>"
    end

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>予約カルテ - #{d[:yoyaku_no]}</title>
        <style>
          @page { size: A4; margin: 6mm; }

          * {
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
            color-adjust: exact !important;
          }

          body {
            font-family: 'IPAGothic', 'MS Gothic', 'Hiragino Kaku Gothic Pro', sans-serif;
            font-size: 7pt;
            margin: 0;
            padding: 3mm;
            line-height: 1.2;
            color: #000;
          }

          /* ============ HEADER ============ */
          .header {
            margin-bottom: 3mm;
            position: relative;
            height: 15mm;
          }

          .print-date {
            position: absolute;
            left: 0;
            top: 0;
            font-size: 6.5pt;
          }

          .title {
            text-align: center;
            font-size: 16pt;
            font-weight: bold;
            letter-spacing: 2px;
            padding-top: 2mm;
          }

          .card-box {
            position: absolute;
            right: 0;
            top: 0;
            width: 12mm;
            border: 1.5px solid #000;
          }

          .card-no {
            text-align: center;
            font-size: 12pt;
            font-weight: bold;
            padding: 1mm 0;
            border-bottom: 1.5px solid #000;
          }

          .card-kana {
            text-align: center;
            font-size: 9pt;
            font-weight: bold;
            padding: 1mm 0;
          }

          /* ============ TABLES ============ */
          table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 1.5mm;
            border: 1px solid #000;
          }

          td, th {
            border: 1px solid #000;
            padding: 1mm 1.5mm;
            vertical-align: middle;
            height: 5mm;
            font-size: 7pt;
          }

          .hdr {
            background-color: #DDDDDD;
            font-weight: normal;
            text-align: center;
          }

          .cell {
            background-color: #FFF;
          }

          /* Dotted borders - cho các cell cần nét đứt */
          .dotted-right {
            border-right: 1px dotted #888 !important;
          }

          .dotted-bottom {
            border-bottom: 1px dotted #888 !important;
          }

          /* ============ NOTES SECTION ============ */
          .notes {
            border: 1px solid #000;
            padding: 2mm 3mm;
            margin-bottom: 1.5mm;
            font-size: 7pt;
            line-height: 1.6;
          }

          .note-line {
            border-bottom: 1px dotted #888;
            padding: 1mm 0;
          }

          .note-line:last-child {
            border-bottom: none;
          }
        </style>
      </head>
      <body>
        <!-- HEADER -->
        <div class="header">
          <div class="print-date">#{d[:print_date]}</div>
          <div class="title">予約カルテ</div>
          <div class="card-box">
            <div class="card-no">#{d[:card_no]}</div>
            <div class="card-kana">#{d[:kana]}</div>
          </div>
        </div>

        <!-- TABLE 1: 予約No row - ALL SOLID borders -->
        <table style="margin-bottom: 1.5mm;">
          <tr style="height: 7mm;">
            #{cell['予約No.', gray: true, w: 22]}
            #{cell[d[:yoyaku_no], w: 43, fs: 9, bold: true]}
            #{cell['予約区分', gray: true, w: 20]}
            #{cell[d[:yoyaku_kubun], w: 18]}
            #{cell['顧客No.', gray: true, w: 20]}
            #{cell[d[:kokyaku_no], w: 12, center: true]}
            #{cell[d[:kokyaku_name]]}
            <td class="cell" style="width: 12mm; text-align: center; font-weight: bold; background: white; border: 1.5px solid #000;">#{d[:kana]}</td>
          </tr>
        </table>

        <!-- TABLE 2: 利用日 row - ALL SOLID borders -->
        <table style="margin-bottom: 3mm;">
          <tr style="height: 5.2mm;">
            #{cell['利用日', gray: true, w: 16]}
            #{cell[d[:riyo_date], w: 38]}
            #{cell['泊日', gray: true, w: 13]}
            #{cell[d[:haku], w: 11]}
            #{cell['受付', gray: true, w: 14]}
            #{cell[d[:uketsuke], w: 55, fs: 6.5]}
            #{cell['営業担当', gray: true, w: 22]}
            #{cell[d[:eigyo_tanto]]}
          </tr>
        </table>

        <!-- TABLE 3: 客名 BLOCK (LEFT) + 予約状況 BLOCK (RIGHT) -->
        <!-- SOLID outer borders, DOTTED internal separators -->
        <table style="margin-bottom: 3mm;">
          <tr class="dotted-bottom">
            #{cell['客名', gray: true, w: 24, dr: true]}
            #{cell[d[:kyaku_name], cs: 4, fs: 8, dr: true]}
            #{cell['予約状況', gray: true, w: 24, dr: true]}
            #{cell[d[:yoyaku_status], dr: true]}
            #{cell['入込', gray: true, w: 14, dr: true]}
            #{cell[d[:nyukon]]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['(ｶﾅ)', gray: true, dr: true]}
            #{cell[d[:kyaku_kana], cs: 4, dr: true]}
            #{cell['有効期限', gray: true, dr: true]}
            #{cell[d[:yuko_kigen], dr: true]}
            #{cell['出発', gray: true, dr: true]}
            #{cell[d[:shuppatsu]]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['(看板名)', gray: true, dr: true]}
            #{cell[d[:kanban], cs: 4, fs: 7, dr: true]}
            #{cell['代表単価', gray: true, dr: true]}
            #{cell[d[:daihyo_tanka], dr: true]}
            #{cell['食事', gray: true, dr: true]}
            #{cell["　#{d[:shokuji]}"]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['幹事', gray: true, dr: true]}
            #{cell[d[:kanji], cs: 4, dr: true]}
            #{cell['利用目的', gray: true, dr: true]}
            #{cell[d[:riyo_mokuteki], dr: true]}
            #{cell['電話', gray: true, rs: 2, dr: true]}
            <td class="cell" rowspan="2" style="font-size: 6.5pt; line-height: 1.3;">#{d[:tel]}/FAX:#{d[:fax]}</td>
          </tr>
          <tr class="dotted-bottom">
            #{cell['企画', gray: true, dr: true]}
            #{cell[d[:kikaku], cs: 4, dr: true]}
            #{cell['支払条件', gray: true, dr: true]}
            #{cell[d[:shiharai], dr: true]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['コース', gray: true, dr: true]}
            #{cell[d[:course], cs: 4, dr: true]}
            #{cell['接客指示', gray: true, dr: true]}
            #{cell[d[:sessaku], dr: true]}
            #{cell['当日', gray: true, dr: true]}
            #{cell[d[:toujitsu]]}
          </tr>
        </table>

        <!-- TABLE 4: ADDRESS SECTION -->
        <!-- SOLID outer, DOTTED internal -->
        <table style="margin-bottom: 3mm;">
          <tr class="dotted-bottom">
            #{cell['顧客住所', gray: true, w: 22, dr: true]}
            #{cell[d[:kokyaku_addr], cs: 7]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['送付住所', gray: true, dr: true]}
            #{cell[d[:sofu_addr], cs: 7]}
          </tr>
          <tr class="dotted-bottom">
            #{cell['役職', gray: true, dr: true]}
            #{cell[d[:yakushoku], cs: 4, dr: true]}
            #{cell['名前', gray: true, cs: 3, center: true]}
          </tr>
          <tr>
            #{cell['業者住所', gray: true, dr: true]}
            #{cell[d[:gyosha_addr], cs: 7]}
          </tr>
        </table>

        <!-- TABLE 5: GUEST COUNT + MEAL TABLE -->
        <!-- SOLID outer + header, DOTTED data rows -->
        <table style="margin-bottom: 3mm;">
          <tr style="height: 4.8mm;">
            #{cell['', th: true, gray: true, w: 17]}
            #{cell['大人', th: true, gray: true]}
            #{cell['男性', th: true, gray: true]}
            #{cell['女性', th: true, gray: true]}
            #{cell['Ａ', th: true, gray: true]}
            #{cell['Ｂ', th: true, gray: true]}
            #{cell['Ｃ', th: true, gray: true]}
            #{cell['Ｄ', th: true, gray: true]}
            #{cell['添乗', th: true, gray: true]}
            #{cell['乗務', th: true, gray: true, dr: true]}
            #{cell['利用名', th: true, gray: true, w: 32]}
            #{cell['人数', th: true, gray: true, w: 10]}
            #{cell['単価', th: true, gray: true, w: 20]}
            #{cell['料理', th: true, gray: true, w: 26]}
            #{cell['朝食', th: true, gray: true]}
          </tr>
          <tr class="dotted-bottom" style="height: 4.8mm;">
            #{cell['総数', gray: true, center: true, dr: true]}
            #{cell['20', center: true, bold: true, dr: true]}
            #{cell['17', center: true, dr: true]}
            #{cell['3', center: true, dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['１泊２食', dr: true]}
            #{cell['20', center: true, dr: true]}
            #{cell['F18,000', dr: true]}
            #{cell['団体Ａ', dr: true]}
            #{cell['和食']}
          </tr>
          <tr class="dotted-bottom" style="height: 4.8mm;">
            #{cell['宿泊', gray: true, center: true, dr: true]}
            #{cell['20', center: true, bold: true, dr: true]}
            #{cell['17', center: true, dr: true]}
            #{cell['3', center: true, dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['１泊２食(添)', dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['F8,000', dr: true]}
            #{cell['バイキング', dr: true]}
            #{cell['バイキング']}
          </tr>
          <tr style="height: 4.8mm;">
            #{cell['日帰', gray: true, center: true, dr: true]}
            #{cell['0', center: true, bold: true, dr: true]}
            #{cell['0', center: true, dr: true]}
            #{cell['0', center: true, dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['0', center: true, dr: true]}
            #{cell['0', center: true, dr: true]}
            #{cell['１泊２食(乗)', dr: true]}
            #{cell['1', center: true, dr: true]}
            #{cell['F8,000', dr: true]}
            #{cell['バイキング', dr: true]}
            #{cell['バイキング']}
          </tr>
        </table>

        <!-- TABLE 6: MEAL SECTION (食事/朝食) -->
        <!-- SOLID outer blocks, DOTTED internal -->
        <table style="width: 51%; margin-bottom: 3mm;">
          <tr style="height: 5.2mm;">
            #{cell['食事', gray: true, rs: 3, w: 7, center: true, dr: true]}
            #{cell['お客様 宴会:桜', cs: 1, fs: 6.5, db: true]}
            #{cell['朝食', gray: true, rs: 3, w: 7, center: true, dr: true]}
            #{cell['お客様 宴会:桜', cs: 1, fs: 6.5, db: true]}
          </tr>
          <tr style="height: 5.2mm;" class="dotted-bottom">
            #{cell['添乗員 バイキング:バイキング', fs: 6.5]}
            #{cell['添乗員 バイキング:バイキング', fs: 6.5]}
          </tr>
          <tr style="height: 5.2mm;">
            #{cell['乗務員 バイキング:バイキング', fs: 6.5]}
            #{cell['乗務員 バイキング:バイキング', fs: 6.5]}
          </tr>
        </table>

        <!-- TABLE 7: 紹介者 -->
        <table style="margin-bottom: 3mm;">
          <tr style="height: 5.2mm;">
            #{cell['紹介者', gray: true, w: 18, dr: true]}
            #{cell['', cs: 5]}
          </tr>
        </table>

        <!-- TABLE 8: 業者/担当/電話 + 案内所/営業所/地区 -->
        <!-- SOLID outer, DOTTED internal -->
        <table style="margin-bottom: 3mm;">
          <tr class="dotted-bottom" style="height: 5.2mm;">
            #{cell['業者', gray: true, w: 14, dr: true]}
            #{cell[d[:gyosha], w: 68, dr: true]}
            #{cell['担当', gray: true, w: 14, dr: true]}
            #{cell[d[:tanto], w: 50, dr: true]}
            #{cell['電話', gray: true, w: 14, dr: true]}
            #{cell[d[:tel_gyosha]]}
          </tr>
          <tr style="height: 5.2mm;">
            #{cell['案内所', gray: true, w: 18, dr: true]}
            #{cell[d[:annaijo], w: 48, dr: true]}
            #{cell['営業所', gray: true, w: 18, dr: true]}
            #{cell[d[:eigyosho], w: 48, dr: true]}
            #{cell['地区', gray: true, w: 14, dr: true]}
            #{cell[d[:chiku]]}
          </tr>
        </table>

        <!-- NOTES SECTION -->
        <div class="notes">
          <div class="note-line">【部屋】おまかせ</div>
          <div class="note-line">【支払】各部屋の利用は個人払い</div>
          <div class="note-line">【料理】１名そばアレルギー</div>
          <div class="note-line">【備考】コンピュータの納入業者</div>
        </div>

        <!-- TABLE 9: 手配 (TEYHAI) -->
        <!-- SOLID outer + header, DOTTED data rows -->
        <table style="margin-bottom: 3mm;">
          <tr style="height: 4.8mm;">
            #{cell['手配名', th: true, gray: true, w: 36]}
            #{cell['数量', th: true, gray: true, w: 14]}
            #{cell['単価', th: true, gray: true, w: 24]}
            #{cell['開始', th: true, gray: true, w: 16]}
            #{cell['終了', th: true, gray: true, w: 16]}
            #{cell['手配先', th: true, gray: true, w: 44]}
            #{cell['備考', th: true, gray: true]}
          </tr>
          <tr class="dotted-bottom" style="height: 4.8mm;">
            #{cell['舟盛り', dr: true]}
            #{cell['2', center: true, dr: true]}
            #{cell['C15,000', dr: true]}
            #{cell['', dr: true]}
            #{cell['', dr: true]}
            #{cell['調理場', dr: true]}
            #{cell['']}
          </tr>
          <tr style="height: 4.8mm;">
            #{cell['コンパニオン', dr: true]}
            #{cell['3', center: true, dr: true]}
            #{cell['C12,000', dr: true]}
            #{cell['19:00', dr: true]}
            #{cell['21:00', dr: true]}
            #{cell['○○コンパ', dr: true]}
            #{cell['若い子希望']}
          </tr>
        </table>

        <!-- TABLE 10: ROOM NUMBERS -->
        <!-- SOLID outer, DOTTED internal vertical separators -->
        <table>
          <tr style="height: 4.8mm;">
            #{cell['桜', center: true, dr: true]}
            #{cell['カラ①', center: true, dr: true]}
            #{cell['300', center: true, dr: true]}
            #{cell['301', center: true, dr: true]}
            #{cell['302', center: true, dr: true]}
            #{cell['303', center: true, dr: true]}
            #{cell['305', center: true, dr: true]}
            #{cell['306', center: true, dr: true]}
            #{cell['307', center: true, dr: true]}
            #{cell['2301', center: true, dr: true]}
            #{cell['2302', center: true]}
          </tr>
        </table>
      </body>
      </html>
    HTML
  end
end

# Run generator
if __FILE__ == $0
  begin
    generator = YoyakuKarteGenerator.new
    generator.generate
  rescue LoadError
    puts '❌ Lỗi: Chưa cài gem'
    puts 'Chạy: gem install wicked_pdf wkhtmltopdf-binary'
  end
end
