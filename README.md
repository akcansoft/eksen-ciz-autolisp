# Eksen Çiz (AutoLisp uygulama)
Bu AutoLISP uygulaması, AutoCAD programında seçilen çember veya yay için dikey ve yatay eksenler çizer.
![](ss-1.png)

## Özellikler
- Çember veya yay için dikey ve yatay eksen çizgisi oluşturur.
- Eksen çizgilerinin uçları, ayarlanan değer kadar dışarı taşar. Çıkıntı ayarlanmadıysa varsayılan değer `3` birimdir
- Çizimler `EKSEN` adlı bir katmanda yapılır.\
Katman yoksa katman eklenir ve aşağıdaki özellikler atanır.\
**Çizgi tipi:** `CENTER` \
**Çizgi rengi:** `4`
$${\color{cyan}■}$$ (cyan = cam göbeği)\
Katman varsa **çizgi tipi** ve **çizgi rengi** değiştirilmez.
- Hata yönetimi ve geri alma (undo) desteği bulunur.

## Yükleme ve çalıştırma
1. **AutoCAD'e Yükleme**  
   `EKSEN-CIZ.LSP` dosyasını AutoCAD'e yüklemek için komut satırına `APPLOAD` yazın ve dosyayı seçin.

2. **Komutu Çalıştırma**  
   Komut satırına `EKSEN` yazın ve `Enter` tuşuna basın.

3. **Merkez Noktası veya Nesne Seçimi**  
Komut, aşağıdaki seçenekleri sunacaktır
- Merkez noktası belirle
- Çıkıntı ayarla
- Nesne seç
- Çıkış

Seçeneklerden seçme işlemini;
- Komut satırında üzerinde tıklayarak,
- Menü baş harfini klavyeden girerek
- Çizim alanında sağ tıklayıp menüden tıklayarak \
verebilrsiniz.

`Nesne seç` varsayılan seçenektir. `Enter`ile seçilebilir. `Nesne seç` ile nesne ya da nesneler seçilir. Seçimi tamamlamak için `Enter` tuşuna basılır. Seçilen nesnelere eksenler çizilir.

Bir seçnek seçilmezse merkez noktası ardından eksen yarıçapı belirlenir.

Program sonsuz döngü ile devam eder. Döngüden çıkmak için `Çıkış` seçeneğini seçin veya `ESC` tuşu ile çıkın.

5. **Eksenlerin Çizilmesi:**\
Program, seçilen nesnenin merkezine göre, sınırlarından ayarlanan çıkıntı değeri kadar taşan yatay ve dikey eksen çizgileri çizecektir. Çıkıntı değeri menüden ayarlanabilir. Başlangıç değeri: `3`

## Dosyalar
- **Kod Dosyaları:**\
   - [`eksen-ciz.lsp`](eksen-ciz.lsp) Türkçe
   - [`eksen-ciz-ENG.lsp`](eksen-ciz-ENG.lsp) English version

## Lisans
Bu uygulama **Mesut Akcan** tarafından geliştirilmiştir. Kaynak belirtmeden paylaşılamaz. Ücretsizdir. Satılamaz.

## İletişim
- **E-posta:** makcan@gmail.com  
- **YouTube Kanalım:** [Mesut Akcan](https://www.youtube.com/mesutakcan)  
- **Blog sayfam:** [Mesut Akcan Blog](https://mesutakcan.blogspot.com)  
> Daha fazla bilgi ve AutoCAD ile ilgili içerikler için [YouTube kanalımı](https://www.youtube.com/mesutakcan) ziyaret edebilirsiniz.

## Katkıda Bulunma
Katkılarınız memnuniyetle karşılanır!\
Özellikler eklemek, hataları düzeltmek veya kodu geliştirmek isterseniz, bir [çekme isteği (Pull Request)](https://github.com/akcansoft/eksen-ciz-autolisp/pulls) açmaktan çekinmeyin.
