# Eksen Çiz (AutoLisp uygulama)
Bu AutoLISP uygulaması, AutoCAD programında seçilen çember veya yay için dikey ve yatay eksenler çizer.

## Özellikler
- Çember veya yay için dikey ve yatay eksen çizgisi oluşturur.
- Eksen çizgilerinin uçları, nesnenin sınırından 3 birim dışarı taşar. Dosyada bu değer değiştirilebilir.
- Çizimler "EKSEN" adlı bir katmanda yapılır.<br>
Katman yoksa katman oluşturulur ve aşağıdaki özellikler atanır.<br>
**Çizgi tipi:** `CENTER` <br>
**Çizgi rengi:** `4` (cyan = cam göbeği)<br>
Katman varsa **çizgi tipi** ve **çizgi rengi** değiştirilmez.
- Hata yönetimi ve geri alma (undo) desteği bulunur.

## Yükleme ve çalıştırma
1. **AutoCAD'e Yükleme**  
   `EKSEN-CIZ.LSP` dosyasını AutoCAD'e yüklemek için komut satırına `APPLOAD` yazın ve dosyayı seçin.

2. **Komutu Çalıştırma**  
   Komut satırına `EKSEN` yazın ve Enter tuşuna basın.

3. **Merkez Noktası veya Nesne Seçimi**  
Komut, sizden merkez noktasını belirlemenizi veya bir nesne seçmenizi isteyecektir.
Merkez noktasını manuel olarak girebilir veya bir çember ya da yay seçebilirsiniz.

4. **Eksenlerin Çizilmesi:** <br>
Program, seçilen nesnenin merkezine göre, sınırlarından 3 birim taşan yatay ve dikey eksen çizgileri çizecektir.

## Dosyalar
- **Kod Dosyası:** [`eksen-ciz.lsp`](eksen-ciz.lsp)

## Lisans
Bu uygulama **Mesut Akcan** tarafından geliştirilmiştir ve eğitim amaçlı kullanımı serbesttir. Kaynak belirtmeden paylaşılmaz.

## İletişim
- **E-posta:** makcan@gmail.com  
- **YouTube Kanalım:** [Mesut Akcan](https://www.youtube.com/mesutakcan)  
- **Blog sayfam:** [Mesut Akcan Blog](https://mesutakcan.blogspot.com)  
> Daha fazla bilgi ve AutoCAD ile ilgili içerikler için [YouTube kanalımı](https://www.youtube.com/mesutakcan) ziyaret edebilirsiniz.

## Katkıda Bulunma
Katkılarınız memnuniyetle karşılanır! Özellikler eklemek, hataları düzeltmek veya kodu geliştirmek isterseniz, bir [çekme isteği (Pull Request)](https://github.com/akcansoft/eksen-ciz-autolisp/pulls) açmaktan çekinmeyin.
