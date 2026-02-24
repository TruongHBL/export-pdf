require 'prawn'
require 'benchmark'

# Sử dụng Noto Sans JP font (đã có sẵn)
FONT_PATH = File.expand_path('~/.fonts/NotoSansJP-Regular.ttf')
OUTPUT    = 'export_with_prawn.pdf'

def mm(x) = x * 2.8346

DATA = {
  print_date:     '印刷：2018/01/16 17:55',
  card_no:        '001',
  kokyaku_kana:   'ｹ',
  yoyaku_no:      '180117-001',
  yoyaku_kubun:   '宿泊',
  kokyaku_no:     '23',
  kokyaku_name:   '株式会社ケイズ',
  riyo_date:      '18/01/17 (水)',
  haku_days:      '1/1',
  uketsuke_date:  '18/01/17 14:10',
  uketsuke_tanto: 'KEIS',
  eigyo_tanto:    '',
  kyaku_name:     '株式会社ケイズ',
  kyaku_kana:     'ｹｲｽﾞ',
  kanban:         '株式会社ケイズ新年会',
  kanji:          '',
  kikaku:         '',
  course:         '',
  yoyaku_status:  '本予約',
  yuko_kigen:     '',
  daihyo_tanka:   'F18,000',
  riyo_mokuteki:  '',
  shiharai:       '',
  sessaku:        '',
  nyuukon:        '',
  shuppatsu:      '',
  choshoku:       '朝食',
  tel:            '0859348902',
  fax:            '0859348912',
  toujitsu:       '',
  yokujitsu:      '',
  kokyaku_addr:   '〒683-0853　鳥取県米子市両三柳2864-16',
  sofu_addr:      '',
  yakushoku:      '',
  namae:          '',
  gyosha_addr:    '〒683-0043　鳥取県米子市末広町181 第一Tﾋﾞﾙ',
  guests: {
    adult:  { total: 20, haku: 20, higaeri: 0 },
    male:   { total: 17, haku: 17, higaeri: 0 },
    female: { total:  3, haku:  3, higaeri: 0 },
    a:      { total: '', haku: '', higaeri: '' },
    b:      { total: '', haku: '', higaeri: '' },
    c:      { total: '', haku: '', higaeri: '' },
    d:      { total: '', haku: '', higaeri: '' },
    tenjo:  { total:  1, haku:  1, higaeri: 0 },
    jomu:   { total:  1, haku:  1, higaeri: 0 },
  },
  banquet_night:   '宴会:桜',
  banquet_morning: '宴会:桜',
  tenjo_night:     'バイキング:バイキング',
  tenjo_morning:   'バイキング:バイキング',
  jomu_night:      'バイキング:バイキング',
  jomu_morning:    'バイキング:バイキング',
  meals: [
    { name: '１泊２食',      count: 20, tanka: 'F18,000', ryori: '団体Ａ',     choshoku: '和食' },
    { name: '１泊２食(添)', count:  1, tanka: 'F8,000',  ryori: 'バイキング', choshoku: 'バイキング' },
    { name: '１泊２食(乗)', count:  1, tanka: 'F8,000',  ryori: 'バイキング', choshoku: 'バイキング' },
  ],
  shokaisha:   '',
  gyosha:      '㈱JTB中国四国 米子支店',
  tanto:       '',
  tel_gyosha:  '',
  annaijo:     '',
  eigyosho:    '',
  chiku:       '鳥取県',
  notes: [
    '【部屋】おまかせ',
    '【支払】各部屋の利用は個人払い',
    '【料理】１名そばアレルギー',
    '【備考】コンピュータの納入業者',
  ],
  teyhai: [
    { name: '舟盛り',       qty: 2, tanka: 'C15,000', start: '',      end: '',      saki: '調理場',      biko: '' },
    { name: 'コンパニオン', qty: 3, tanka: 'C12,000', start: '19:00', end: '21:00', saki: '○○コンパ', biko: '若い子希望' },
  ],
  rooms: ['桜', 'カラ①', '300', '301', '302', '303', '305', '306', '307', '2301', '2302'],
}

elapsed_time = Benchmark.realtime do
  Prawn::Document.generate(OUTPUT,
    page_size: 'A4',
    margin:    [mm(6), mm(6), mm(6), mm(6)],
    compress:  true
  ) do |pdf|

  pdf.font_families.update('J' => { normal: { file: FONT_PATH } })
  pdf.font 'J'

  PW  = pdf.bounds.width
  PH  = pdf.bounds.height
  RH  = mm(5.2)
  RHs = mm(4.8)

  BC  = '888888'   # border color
  HC  = 'DDDDDD'   # header fill color

  # ─── Primitive drawing helpers ───────────────────────────────────────────

  # Write text at baseline (x, y). align: :left/:center/:right
  wt = ->(x, y, text, size: 7, align: :left) do
    pdf.font_size size
    pdf.fill_color '000000'
    s  = text.to_s
    tx = case align
         when :center then x - pdf.width_of(s, size: size) / 2.0
         when :right  then x - pdf.width_of(s, size: size)
         else x
         end
    pdf.draw_text s, at: [tx, y]
  end

  # Solid rectangle border (x, y = bottom-left)
  solid = ->(x, y, w, h, lw: 0.4) do
    pdf.stroke_color BC
    pdf.line_width   lw
    pdf.stroke_rectangle [x, y + h], w, h
  end

  # Dashed rectangle border
  dashed = ->(x, y, w, h, lw: 0.3) do
    pdf.stroke_color BC
    pdf.line_width   lw
    pdf.dash(2, space: 2)
    pdf.stroke_rectangle [x, y + h], w, h
    pdf.undash
  end

  # Gray-filled + solid border
  hdr_box = ->(x, y, w, h) do
    pdf.fill_color HC
    pdf.fill_rectangle [x, y + h], w, h
    pdf.fill_color '000000'
    solid.call(x, y, w, h)
  end

  # ─── Solid horizontal line ────────────────────────────────────────────────
  hline_s = ->(x1, y, x2, lw: 0.4) do
    pdf.stroke_color BC; pdf.line_width lw
    pdf.stroke_line [x1, y], [x2, y]
  end

  # Dashed horizontal line
  hline_d = ->(x1, y, x2, lw: 0.3) do
    pdf.stroke_color BC; pdf.line_width lw
    pdf.dash(2, space: 2)
    pdf.stroke_line [x1, y], [x2, y]
    pdf.undash
  end

  # Solid vertical line
  vline_s = ->(x, y1, y2, lw: 0.4) do
    pdf.stroke_color BC; pdf.line_width lw
    pdf.stroke_line [x, y1], [x, y2]
  end

  # Dashed vertical line
  vline_d = ->(x, y1, y2, lw: 0.3) do
    pdf.stroke_color BC; pdf.line_width lw
    pdf.dash(2, space: 2)
    pdf.stroke_line [x, y1], [x, y2]
    pdf.undash
  end

  # ─── Cell helpers ────────────────────────────────────────────────────────
  # Draw text inside a cell area (no border drawn here)
  cell_text = ->(x, y, w, h, text, size: 7, align: :left, pl: mm(1.5)) do
    s = text.to_s.strip
    return if s.empty?
    ty = y + h / 2.0 - size * 0.36
    case align
    when :center then wt.call(x + w / 2.0, ty, s, size: size, align: :center)
    when :right  then wt.call(x + w - pl,  ty, s, size: size, align: :right)
    else              wt.call(x + pl,       ty, s, size: size)
    end
  end

  # Full solid cell (border + optional gray fill + text)
  scell = ->(x, y, w, h, text: '', size: 7, fill: false, align: :left) do
    fill ? hdr_box.call(x, y, w, h) : solid.call(x, y, w, h)
    cell_text.call(x, y, w, h, text, size: size, align: align)
  end

  # ─── Y cursor ───────────────────────────────────────────────────────────
  y = PH

  # ══════════════════════════════════════════════════════════════════════════
  # S1  HEADER
  # ══════════════════════════════════════════════════════════════════════════
  y -= mm(5)
  wt.call(0, y, DATA[:print_date], size: 6.5)
  wt.call(PW / 2.0, y, '予約カルテ', size: 16, align: :center)

  # 001 / ｹ stacked boxes (top-right, solid thick border)
  bw = mm(12); bh1 = mm(6); bh2 = mm(5); bx = PW - bw
  solid.call(bx, y - mm(0.5),         bw, bh1, lw: 0.8)
  wt.call(bx + bw/2, y - mm(0.5) + mm(1.5),     DATA[:card_no],     size: 12, align: :center)
  solid.call(bx, y - mm(0.5) - bh2,   bw, bh2, lw: 0.8)
  wt.call(bx + bw/2, y - mm(0.5) - bh2 + mm(1.2), DATA[:kokyaku_kana], size: 9, align: :center)

  y -= mm(3)

  # ══════════════════════════════════════════════════════════════════════════
  # S2  予約No. row  ── ALL SOLID (prominent outer row)
  # ══════════════════════════════════════════════════════════════════════════
  r2h = mm(7); cw2 = PW - bw
  wl1=mm(22); wv1=mm(43); wl2=mm(20); wv2=mm(18); wl3=mm(20); wv3=mm(12)
  wname = cw2 - wl1 - wv1 - wl2 - wv2 - wl3 - wv3

  # Outer solid border for entire row
  solid.call(0, y-r2h, cw2, r2h, lw: 0.6)
  solid.call(cw2, y-r2h, bw, r2h, lw: 0.6)

  # Internal vertical separators (solid)
  [wl1, wl1+wv1, wl1+wv1+wl2, wl1+wv1+wl2+wv2, wl1+wv1+wl2+wv2+wl3, wl1+wv1+wl2+wv2+wl3+wv3].each do |xv|
    vline_s.call(xv, y-r2h, y, lw: 0.4)
  end

  # Header fills
  [0, wl1+wv1, wl1+wv1+wl2+wv2].each_with_index do |xv, i|
    w = [wl1, wl2, wl3][i]
    hdr_box.call(xv, y-r2h, w, r2h)
  end

  # Text
  cell_text.call(0,                           y-r2h, wl1,   r2h, '予約No.')
  cell_text.call(wl1,                          y-r2h, wv1,   r2h, DATA[:yoyaku_no],   size: 11)
  cell_text.call(wl1+wv1,                      y-r2h, wl2,   r2h, '予約区分')
  cell_text.call(wl1+wv1+wl2,                  y-r2h, wv2,   r2h, DATA[:yoyaku_kubun])
  cell_text.call(wl1+wv1+wl2+wv2,              y-r2h, wl3,   r2h, '顧客No.')
  cell_text.call(wl1+wv1+wl2+wv2+wl3,          y-r2h, wv3,   r2h, DATA[:kokyaku_no], align: :center)
  cell_text.call(wl1+wv1+wl2+wv2+wl3+wv3,      y-r2h, wname, r2h, DATA[:kokyaku_name])
  y -= r2h

  # ══════════════════════════════════════════════════════════════════════════
  # S3  利用日 row  ── ALL SOLID
  # ══════════════════════════════════════════════════════════════════════════
  w1=mm(16); w2=mm(38); w3=mm(13); w4=mm(11); w5=mm(14); w6=mm(55); w7=mm(22)
  w8 = PW - w1-w2-w3-w4-w5-w6-w7
  ws3 = [w1,w2,w3,w4,w5,w6,w7,w8]
  lbls3 = ['利用日', nil, '泊日', nil, '受付', nil, '営業担当', nil]
  vals3 = ['利用日', DATA[:riyo_date], '泊日', DATA[:haku_days], '受付',
           "#{DATA[:uketsuke_date]} #{DATA[:uketsuke_tanto]}", '営業担当', DATA[:eigyo_tanto]]
  hdrs3 = [true, false, true, false, true, false, true, false]

  solid.call(0, y-RH, PW, RH, lw: 0.5)
  x = 0
  ws3.each_with_index do |w, i|
    vline_s.call(x, y-RH, y) if i > 0
    hdr_box.call(x, y-RH, w, RH) if hdrs3[i]
    cell_text.call(x, y-RH, w, RH, vals3[i])
    x += w
  end
  y -= RH
  y -= mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S4  客名 BLOCK (left) | 予約状況 BLOCK (right)
  #
  # Border rules (from image):
  #   • Outer border of each block → SOLID
  #   • Internal horizontal lines between rows → DASHED
  #   • Vertical separator between label/value → DASHED
  # ══════════════════════════════════════════════════════════════════════════
  lw_blk = PW * 0.455;  rw_blk = PW - lw_blk
  ll  = mm(24)
  rl1 = mm(24); rl2 = mm(14)
  rv1 = rw_blk * 0.375; rv2 = rw_blk - rl1 - rv1 - rl2

  left_rows = [
    ['客名',     DATA[:kyaku_name],  8.5],
    ['(ｶﾅ)',    DATA[:kyaku_kana],  7],
    ['(看板名)', DATA[:kanban],      7],
    ['幹事',     DATA[:kanji],       7],
    ['企画',     DATA[:kikaku],      7],
    ['コース',   DATA[:course],      7],
  ]
  right_rows = [
    ['予約状況', DATA[:yoyaku_status],                 '入込', DATA[:nyuukon]],
    ['有効期限', DATA[:yuko_kigen],                    '出発', DATA[:shuppatsu]],
    ['代表単価', DATA[:daihyo_tanka],                  '食事', "　#{DATA[:choshoku]}"],
    ['利用目的', DATA[:riyo_mokuteki],                 '電話', "#{DATA[:tel]}/FAX:#{DATA[:fax]}"],
    ['支払条件', DATA[:shiharai],                      '当日', DATA[:toujitsu]],
    ['接客指示', DATA[:sessaku],                       '翌日', DATA[:yokujitsu]],
  ]

  n_rows = [left_rows.size, right_rows.size].max
  total_h = n_rows * RH
  y_top = y

  # ── Left block: solid outer, dashed inner ──
  solid.call(0, y_top - total_h, lw_blk, total_h, lw: 0.5)   # outer solid
  yl = y_top
  left_rows.each_with_index do |(lbl, val, sz), i|
    hdr_box.call(0, yl-RH, ll, RH)                             # gray label always solid
    cell_text.call(0,  yl-RH, ll,      RH, lbl)
    cell_text.call(ll, yl-RH, lw_blk-ll, RH, val, size: sz)
    # dashed horizontal separator (not last row)
    hline_d.call(0, yl-RH, lw_blk) if i < left_rows.size - 1
    # dashed vertical label/value separator
    vline_d.call(ll, yl-RH, yl)
    yl -= RH
  end

  # ── Right block: solid outer, dashed inner ──
  solid.call(lw_blk, y_top - total_h, rw_blk, total_h, lw: 0.5)
  yr = y_top
  right_rows.each_with_index do |(l1, v1, l2, v2), i|
    hdr_box.call(lw_blk,              yr-RH, rl1, RH)
    hdr_box.call(lw_blk+rl1+rv1,      yr-RH, rl2, RH)
    cell_text.call(lw_blk,             yr-RH, rl1, RH, l1)
    cell_text.call(lw_blk+rl1,         yr-RH, rv1, RH, v1.to_s, size: 7)
    cell_text.call(lw_blk+rl1+rv1,     yr-RH, rl2, RH, l2)
    cell_text.call(lw_blk+rl1+rv1+rl2, yr-RH, rv2, RH, v2.to_s, size: 6.5)
    # dashed horizontal separator (not last row)
    hline_d.call(lw_blk, yr-RH, PW) if i < right_rows.size - 1
    # dashed vertical separators inside right block
    vline_d.call(lw_blk+rl1,       yr-RH, yr)
    vline_d.call(lw_blk+rl1+rv1,   yr-RH, yr)
    vline_d.call(lw_blk+rl1+rv1+rl2, yr-RH, yr)
    yr -= RH
  end

  y = [yl, yr].min - mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S5  ADDRESS block
  #
  # Border rules:
  #   • Outer border → SOLID
  #   • Internal horizontal lines → DASHED
  #   • Internal vertical separators → DASHED
  # ══════════════════════════════════════════════════════════════════════════
  al = mm(22); ha = mm(5)
  addr_rows = [
    ['顧客住所', DATA[:kokyaku_addr], nil,    nil],
    ['送付住所', DATA[:sofu_addr],    nil,    nil],
    ['役職',     DATA[:yakushoku],    '名前', DATA[:namae]],
    ['業者住所', DATA[:gyosha_addr],  nil,    nil],
  ]
  addr_total_h = addr_rows.size * ha

  solid.call(0, y - addr_total_h, PW, addr_total_h, lw: 0.5)  # outer solid

  addr_rows.each_with_index do |(lbl, val, lbl2, val2), i|
    hdr_box.call(0, y-ha, al, ha)
    cell_text.call(0, y-ha, al, ha, lbl)
    hline_d.call(0, y-ha, PW) if i < addr_rows.size - 1   # dashed bottom separator
    vline_d.call(al, y-ha, y)                               # dashed vertical
    if lbl2
      half = PW / 2.0
      cell_text.call(al,          y-ha, half-al,     ha, val.to_s)
      hdr_box.call(half,           y-ha, mm(14),      ha)
      cell_text.call(half,         y-ha, mm(14),      ha, lbl2)
      cell_text.call(half+mm(14),  y-ha, half-mm(14), ha, val2.to_s)
      vline_d.call(half,           y-ha, y)
      vline_d.call(half+mm(14),    y-ha, y)
    else
      cell_text.call(al, y-ha, PW-al, ha, val.to_s)
    end
    y -= ha
  end
  y -= mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S6  GUEST COUNT (left 47%) + MEAL TABLE (right 53%)
  #
  # Border rules:
  #   • Entire outer border → SOLID
  #   • Header row borders → SOLID (filled gray)
  #   • Data row horizontal separators → DASHED
  #   • Internal vertical separators → DASHED (except outer edges)
  # ══════════════════════════════════════════════════════════════════════════
  gw    = PW * 0.47
  mw_t  = PW - gw
  g_lbl = mm(17)
  g_cw  = (gw - g_lbl) / 9.0
  m_ws  = [mm(32), mm(10), mm(20), mm(26), mw_t - mm(88)]
  m_hdr = ['利用名', '人数', '単価', '料理', '朝食']

  total_rows_h = RHs * 4  # 1 header + 3 data
  solid.call(0, y - total_rows_h, PW, total_rows_h, lw: 0.5)

  # ── Guest table header row (all solid fill + solid borders) ──
  hdr_box.call(0, y-RHs, g_lbl, RHs)
  %w[大人 男性 女性 Ａ Ｂ Ｃ Ｄ 添乗 乗務].each_with_index do |lbl, i|
    hdr_box.call(g_lbl + i*g_cw, y-RHs, g_cw, RHs)
    cell_text.call(g_lbl + i*g_cw, y-RHs, g_cw, RHs, lbl, align: :center)
    vline_s.call(g_lbl + i*g_cw, y-RHs, y) if i > 0
  end
  vline_s.call(g_lbl, y-RHs, y)

  # ── Meal table header row ──
  xm = gw
  m_hdr.zip(m_ws).each_with_index do |(lbl, mw), i|
    hdr_box.call(xm, y-RHs, mw, RHs)
    cell_text.call(xm, y-RHs, mw, RHs, lbl, align: :center)
    vline_s.call(xm, y-RHs, y) if i > 0
    xm += mw
  end
  vline_s.call(gw, y-RHs, y)   # separator between guest/meal tables
  y -= RHs

  # ── Guest/Meal data rows ──
  g = DATA[:guests]
  [[:total, '総数'], [:haku, '宿泊'], [:higaeri, '日帰']].each_with_index do |(key, lbl), ri|
    # Dashed bottom separator (not last row)
    hline_d.call(0, y-RHs, PW) if ri < 2

    # Guest label (gray)
    hdr_box.call(0, y-RHs, g_lbl, RHs)
    cell_text.call(0, y-RHs, g_lbl, RHs, lbl, align: :center)

    # Guest data cells
    [g[:adult], g[:male], g[:female], g[:a], g[:b], g[:c], g[:d], g[:tenjo], g[:jomu]]
      .each_with_index do |col, ci|
        vline_d.call(g_lbl + ci*g_cw, y-RHs, y)
        cell_text.call(g_lbl + ci*g_cw, y-RHs, g_cw, RHs, col[key].to_s, align: :center)
      end
    vline_d.call(g_lbl + 9*g_cw, y-RHs, y)   # right edge of guest area = left of meal

    # Meal data cells
    if ri < DATA[:meals].size
      m = DATA[:meals][ri]; xm = gw
      m_ws.each_with_index do |mw, mi|
        vline_d.call(xm, y-RHs, y) if mi > 0
        val = [m[:name], m[:count], m[:tanka], m[:ryori], m[:choshoku]][mi]
        cell_text.call(xm, y-RHs, mw, RHs, val.to_s, size: 6.5)
        xm += mw
      end
    end
    y -= RHs
  end
  y -= mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S7  食事 SECTION
  #
  # Border rules:
  #   • Outer border of left half / right half → SOLID
  #   • '食事'/'朝食' label vertical right edge → DASHED
  #   • Internal row separators → DASHED
  # ══════════════════════════════════════════════════════════════════════════
  sw    = PW * 0.51
  s_lbl = mm(7)
  s_col = sw / 2.0 - s_lbl
  s_h   = RH * 3

  # Outer solid border: left half + right half
  solid.call(0,      y - s_h, sw / 2.0, s_h, lw: 0.5)
  solid.call(sw/2.0, y - s_h, sw / 2.0, s_h, lw: 0.5)

  # '食事' label (gray, solid outer)
  hdr_box.call(0,      y-s_h, s_lbl, s_h)
  cell_text.call(0,    y-s_h, s_lbl, s_h, '食事', align: :center)

  # '朝食' label (gray, solid outer)
  hdr_box.call(sw/2.0, y-s_h, s_lbl, s_h)
  cell_text.call(sw/2.0, y-s_h, s_lbl, s_h, '朝食', align: :center)

  sy = y
  [
    ["お客様#{DATA[:banquet_night]}",  "お客様#{DATA[:banquet_morning]}"],
    ["添乗員#{DATA[:tenjo_night]}",    "添乗員#{DATA[:tenjo_morning]}"],
    ["乗務員#{DATA[:jomu_night]}",     "乗務員#{DATA[:jomu_morning]}"],
  ].each_with_index do |(night, morning), i|
    cell_text.call(s_lbl,           sy-RH, s_col, RH, night,   size: 6.5)
    cell_text.call(sw/2.0 + s_lbl,  sy-RH, s_col, RH, morning, size: 6.5)
    # dashed separators between rows (not last)
    hline_d.call(0,      sy-RH, sw/2.0) if i < 2
    hline_d.call(sw/2.0, sy-RH, sw)     if i < 2
    # dashed vertical: label | content
    vline_d.call(s_lbl,          sy-RH, sy)
    vline_d.call(sw/2.0 + s_lbl, sy-RH, sy)
    sy -= RH
  end
  y -= s_h + mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S8  紹介者  ── SOLID outer, DASHED vertical
  # ══════════════════════════════════════════════════════════════════════════
  solid.call(0, y-RH, PW, RH, lw: 0.5)
  hdr_box.call(0, y-RH, mm(18), RH)
  vline_d.call(mm(18), y-RH, y)
  cell_text.call(0,      y-RH, mm(18), RH, '紹介者')
  cell_text.call(mm(18), y-RH, PW-mm(18), RH, DATA[:shokaisha].to_s)
  y -= RH + mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S9  業者/担当/電話  +  案内所/営業所/地区
  #
  # Border rules:
  #   • Outer border → SOLID
  #   • Internal horizontal separator → DASHED
  #   • Internal vertical separators → DASHED
  # ══════════════════════════════════════════════════════════════════════════
  biz_h = RH * 2
  solid.call(0, y - biz_h, PW, biz_h, lw: 0.5)

  # Row 1: 業者/担当/電話
  b1l=mm(14); b1v=mm(68); b2l=mm(14); b2v=mm(50); b3l=mm(14); b3v=PW-b1l-b1v-b2l-b2v-b3l
  hdr_box.call(0,           y-RH, b1l, RH); cell_text.call(0,           y-RH, b1l, RH, '業者')
  cell_text.call(b1l,         y-RH, b1v, RH, DATA[:gyosha])
  hdr_box.call(b1l+b1v,       y-RH, b2l, RH); cell_text.call(b1l+b1v,   y-RH, b2l, RH, '担当')
  cell_text.call(b1l+b1v+b2l, y-RH, b2v, RH, DATA[:tanto])
  hdr_box.call(b1l+b1v+b2l+b2v, y-RH, b3l, RH); cell_text.call(b1l+b1v+b2l+b2v, y-RH, b3l, RH, '電話')
  cell_text.call(b1l+b1v+b2l+b2v+b3l, y-RH, b3v, RH, DATA[:tel_gyosha])
  [b1l, b1l+b1v, b1l+b1v+b2l, b1l+b1v+b2l+b2v, b1l+b1v+b2l+b2v+b3l].each { |xv| vline_d.call(xv, y-RH, y) }
  hline_d.call(0, y-RH, PW)
  y -= RH

  # Row 2: 案内所/営業所/地区
  a1l=mm(18); a1v=mm(48); a2l=mm(18); a2v=mm(48); a3l=mm(14); a3v=PW-a1l-a1v-a2l-a2v-a3l
  hdr_box.call(0,           y-RH, a1l, RH); cell_text.call(0,           y-RH, a1l, RH, '案内所')
  cell_text.call(a1l,         y-RH, a1v, RH, DATA[:annaijo])
  hdr_box.call(a1l+a1v,       y-RH, a2l, RH); cell_text.call(a1l+a1v,   y-RH, a2l, RH, '営業所')
  cell_text.call(a1l+a1v+a2l, y-RH, a2v, RH, DATA[:eigyosho])
  hdr_box.call(a1l+a1v+a2l+a2v, y-RH, a3l, RH); cell_text.call(a1l+a1v+a2l+a2v, y-RH, a3l, RH, '地区')
  cell_text.call(a1l+a1v+a2l+a2v+a3l, y-RH, a3v, RH, DATA[:chiku])
  [a1l, a1l+a1v, a1l+a1v+a2l, a1l+a1v+a2l+a2v, a1l+a1v+a2l+a2v+a3l].each { |xv| vline_d.call(xv, y-RH, y) }
  y -= RH + mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S10  NOTES
  #
  # Border rules:
  #   • Outer border of entire notes block → SOLID
  #   • Each row: solid left/right edges, DASHED bottom separator
  # ══════════════════════════════════════════════════════════════════════════
  notes_h = DATA[:notes].size * RH
  solid.call(0, y - notes_h, PW, notes_h, lw: 0.5)

  DATA[:notes].each_with_index do |note, i|
    cell_text.call(0, y-RH, PW, RH, note, size: 7)
    hline_d.call(0, y-RH, PW) if i < DATA[:notes].size - 1
    y -= RH
  end
  y -= mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S11  手配 TABLE
  #
  # Border rules:
  #   • Outer border → SOLID
  #   • Header row: all SOLID (gray filled)
  #   • Data rows: DASHED bottom separator, DASHED vertical separators
  # ══════════════════════════════════════════════════════════════════════════
  t_hdrs = ['手配名', '数量', '単価', '開始', '終了', '手配先', '備考']
  t_ws   = [mm(36), mm(14), mm(24), mm(16), mm(16), mm(44), PW - mm(150)]
  teyhai_h = RHs * (1 + DATA[:teyhai].size)
  solid.call(0, y - teyhai_h, PW, teyhai_h, lw: 0.5)

  # Header
  x = 0
  t_hdrs.zip(t_ws).each_with_index do |(lbl, tw), i|
    hdr_box.call(x, y-RHs, tw, RHs)
    cell_text.call(x, y-RHs, tw, RHs, lbl, align: :center)
    vline_s.call(x, y-RHs, y) if i > 0
    x += tw
  end
  y -= RHs

  # Data rows
  DATA[:teyhai].each_with_index do |t, ri|
    hline_d.call(0, y-RHs, PW) if ri < DATA[:teyhai].size - 1
    x = 0
    [t[:name], t[:qty].to_s, t[:tanka], t[:start], t[:end], t[:saki], t[:biko]].zip(t_ws).each_with_index do |(val, tw), ci|
      vline_d.call(x, y-RHs, y) if ci > 0
      cell_text.call(x, y-RHs, tw, RHs, val.to_s, size: 6.5)
      x += tw
    end
    y -= RHs
  end
  y -= mm(1.5)

  # ══════════════════════════════════════════════════════════════════════════
  # S12  ROOM ROW  ── SOLID outer, DASHED internal separators
  # ══════════════════════════════════════════════════════════════════════════
  rw_each = PW / DATA[:rooms].size.to_f
  solid.call(0, y-RHs, PW, RHs, lw: 0.5)
  DATA[:rooms].each_with_index do |room, i|
    vline_d.call(i * rw_each, y-RHs, y) if i > 0
    cell_text.call(i * rw_each, y-RHs, rw_each, RHs, room, size: 7, align: :center)
  end

  end  # end of Prawn::Document.generate block
end  # end of Benchmark.realtime block

file_size = File.size(OUTPUT) / 1024.0  # KB

puts "✅ PDF saved: #{OUTPUT}"
puts "⏱️  Generation time: #{(elapsed_time * 1000).round(2)} ms"
puts "📦 File size: #{file_size.round(2)} KB"
puts "🚀 Speed: Prawn (Pure Ruby)"
