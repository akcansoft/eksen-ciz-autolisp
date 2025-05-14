;| EKSEN
Çember veya yay'a dikey ve yatay eksenleri çizer
Kullanýcý, nesne seçimi veya merkez noktasý belirleme ile eksen çizebilir.
Çýkýntý mesafesi ayarlanabilir.
Son iþlem geri alýnabilir.

12/12/2024 - Ýlk sürüm
14/05/2025 - Son güncelleme

R14

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)
(setq cikinti 3) ; Çýkýntý mesafesi

(defun c:EKSEN (/ cikis doc edata eksenSayisi ent menuSecimi menuTxt n ss yeniCikinti) 
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))  ; aktif çizim
  ; Çalýþma sýrasýnda hata olursa
  (defun *error* (msg) 
    (vla-endundomark doc)
    (if msg (princ (strcat "\nHata: " msg)))
    (princ)
  )

  ; Eksen katmaný yoksa ekle
  (KatmanEkle "EKSEN" "CENTER" 4) ; Katman adý, çizgi tipi ve çizgi rengi
  (setq eksenSayisi 0) ; Eksen sayýsý
  
  ; Çýkýþ seçilene kadar sonsuz döngü
  (while (null cikis) 
    ; Seçenekler:
		; -----------
    ; 1-Merkez noktasý týkla
    ; 2-Çýkýntý ayarla
    ; 3-Geri al
    ; 4-Çýkýþ
		; 5-Nesne seç (Varsayýlan seçenek)
    (prompt (strcat "\nÇýkýntý:" (rtos cikinti))) ; Çýkýntý mesafesi
    (initget "Nesne Ayarla Geri Çýkýþ") ; Menü elemanlarý
    (setq menuTxt (strcat "[Nesne seç/çýkýntý Ayarla" (if (> eksenSayisi 0) "/Geri al" "") "/Çýkýþ]"))
    (setq menuSecimi ; Menü seçimi
          (getpoint (strcat "\nMerkez noktasý belirle " menuTxt " <Nesne seç>: "))
    )

    (cond 
      ;1-Merkez noktasý týklandý ise
      ;-----------------------------
      ((= 'LIST (type menuSecimi)) ; Dönen deðer liste ise
       (EksenCiz menuSecimi (getdist menuSecimi "\nEksen yarýçapý:") cikinti doc)
       (setq eksenSayisi (1+ eksenSayisi))
      )

      ;2-"Çýkýntý ayarla" seçildi ise
      ((= menuSecimi "Ayarla") ; Dönen deðer "Ayarla" ise
        ; Çýkýntý mesafesini ayarla
        (setq yeniCikinti (getdist (strcat "\nÇýkýntý mesafesi <" (rtos cikinti) ">: ")))
        (if yeniCikinti (setq cikinti yeniCikinti))
      )

      ;3-"Geri al" seçildi ise
      ; ---------------------
      ((= menuSecimi "Geri")
       (progn
         (repeat 2 (entdel (entlast))); Son iki çizgiyi sil
         (setq eksenSayisi (1- eksenSayisi)); Eksen sayýsýný azalt
       )
      )

      ;4-"Çýkýþ" seçildi ise
      ; ------------------
      ((= menuSecimi "Çýkýþ") (setq cikis T))

      ;5-"Nesne seç" seçildi veya Enter'e basýldý ise
      ;---------------------------------------------
      (T
       (if (setq ss (ssget '((0 . "CIRCLE,ARC"))))  ; Yay veya çember seç
         ;seçim yapýldýysa
         ;----------------
         (progn 
           (repeat (setq n (sslength ss))  ; Seçili nesne sayýsý kadar döngü
             (setq ent (ssname ss (setq n (1- n))) ; seçim listesindeki varlýk adý
                   edata (entget ent) ; Varlýk verileri. DXF bilgiler
             )
             (EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)) cikinti doc)
             (setq eksenSayisi (1+ eksenSayisi))
           );repeat
         );progn

         ;seçim yapýlmadýysa
         ;------------------
         (prompt "\n*Çember veya yay seçilmedi!*")
       );if
      );T
    );cond
  );while
  (princ)
);defun

; Eksen çiz
; ---------
; Çember veya yay'a dikey ve yatay eksenleri çizer
; mn: Merkez noktasý
; r: Yarýçap
; c: Çýkýntý mesafesi
; d: Aktif belge
(defun EksenCiz (mn r c d)  ; Merkez nokta, yarýçap, çýkýntý, doc
  (setq r (+ r c)) ; Çýkýntýyý yarýçapa ekle
  ; Eksenleri çiz
	(vla-startundomark d)
  ; 0 ve 90 derece açýlarý için döngü
  (foreach aci (list 0 (/ pi 2))
    (entmake 
      (list 
        (cons 0 "LINE") ; Nesne tipi
        (cons 8 "EKSEN") ; Katman
        (cons 10 (trans (polar mn aci r) 1 0)) ; Baþlangýç noktasý
        (cons 11 (trans (polar mn (+ pi aci) r) 1 0)) ; Bitiþ noktasý
      );list
    );entmake
  );foreach
	(vla-endundomark d)
);defun

; Katman Ekle
; --------------
; Belirtilen ad, çizgi tipi ve çizgi rengi ile yeni bir katman oluþturur.
; katmanAdi - Oluþturulacak katmanýn adý.
; cizgiTipi - Katmana atanacak çizgi tipi.
; cizgiRengi - Katmana atanacak renk.  
(defun KatmanEkle (katmanAdi cizgiTipi cizgiRengi) 
  ; Çizgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgiTipi))  ; Çizgi tipi yoksa
    (progn 
      (command "-linetype" "load" cizgiTipi "acadiso.lin" "") ; Çizgi tipini yükle
      (if (not (tblsearch "LTYPE" cizgiTipi)) ; Çizgi tipi yüklenemediyse
        (princ (strcat "\n" cizgiTipi " çizgi tipi yüklenemedi."))
      );if
    );progn
  );if
  
  ; Katmaný kontrol et
  (if (not (tblsearch "LAYER" katmanAdi))  ; Katman yoksa
    (entmake  ; Katman yap
      (list 
        (cons 0 "LAYER") ; Katman
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")
        (cons 70 0) ; Katman durumu ON
        (cons 2 katmanAdi) ; Katman adý
        (cons 6 cizgiTipi) ; Çizgi tipi
        (cons 62 cizgiRengi) ; Çizgi rengi
        (cons 370 -3) ; Çizgi kalýnlýðý. Default
      );list
    );entmake
  );if
);defun
;--
