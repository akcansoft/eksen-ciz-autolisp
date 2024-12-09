# Eksen Çiz (AutoLisp uygulama)
Bu AutoLISP uygulaması, AutoCAD programında seçilen çember veya yay için dikey ve yatay eksenler çizer.

## Özellikler
- Çember veya yay için dikey ve yatay eksen çizgisi oluşturur.
- Eksen çizgilerinin uçları, nesnenin sınırından 3 birim dışarı taşar. Dosyada bu değer değiştirilebilir.
- Çizimler "EKSEN" adlı bir katmanda yapılır.
- Eksenler için `CENTER2` çizgi tipi ve `4` (cyan = cam göbeği) çizgi rengi kullanılır.
- Hata yönetimi ve geri alma (undo) desteği bulunur.

## Yükleme ve çalıştırma
1. **AutoCAD'e Yükleme**  
   `EKSEN-CIZ.LSP` dosyasını AutoCAD'e yüklemek için komut satırına `APPLOAD` yazın ve dosyayı seçin.

2. **Komutu Çalıştırma**  
   Komut satırına `EKSEN` yazın ve Enter tuşuna basın.

3. **Merkez Noktası veya Nesne Seçimi**  
   - Çizim alanında bir merkez noktası belirleyin ve eksen yarıçapı uzunluğunu belirtin **veya**  
   - Bir çember veya yay nesnesi seçin.

4. **Sonuç**  
   - Seçili Çember veya yaya dikey ve yatay eksenler çizilecektir.

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
