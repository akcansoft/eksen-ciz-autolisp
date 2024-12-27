;| EKSEN
Çember veya yay'a dikey ve yatay eksenleri çizer
Kullanýcý, nesne seçimi veya merkez noktasý belirleme ile eksen çizebilir.
Çýkýntý mesafesi ayarlanabilir.
Son iþlem geri alýnabilir.

12/12/2024 - Ýlk sürüm
27/12/2024 - Son güncelleme

R13

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)
(setq
  doc (vla-get-activedocument (vlax-get-acad-object)) ; aktif çizim
  cikinti 3 ; Çýkýntý mesafesi
)

(defun c:EKSEN (/ cikis edata ent menu-secimi n ss eksensayisi menutxt) 
  ; Çalýþma sýrasýnda hata olursa
  (defun *error* (msg) 
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nHata: " msg)))
    (princ)
  )

  ; Eksen katmaný yoksa ekle
  (KatmanEkle "EKSEN" "CENTER" 4) ; Katman adý, çizgi tipi ve çizgi rengi
  (setq eksensayisi 0) ; Eksen sayýsý
  
  ; Çýkýþ seçilene kadar sonsuz döngü
  (while (null cikis) 
    ; Seçenekler:
		; -----------
    ; 1-Merkez noktasý týkla
    ; 2-Çýkýntý ayarla
    ; 3-Nesne seç (Varsayýlan seçenek)
    ; 4-Geri al
    ; 5-Çýkýþ
    (prompt (strcat "\nÇýkýntý:" (rtos cikinti))) ; Çýkýntý mesafesi
    (initget "Nesne Ayarla Geri Çýkýþ") ; Menü elemanlarý
    (setq menutxt (strcat "[Nesne seç/çýkýntý Ayarla" (if (> eksensayisi 0) "/Geri al" "") "/Çýkýþ]"))
    (setq menu-secimi ; Menü seçimi
          (getpoint (strcat "\nMerkez noktasý belirle " menutxt " <Nesne seç>: "))
    )

    (cond 
      ;1-Merkez noktasý týklandý ise
      ;-----------------------------
      ((= 'LIST (type menu-secimi)) ; Dönen deðer liste ise
       (EksenCiz menu-secimi (getdist menu-secimi "\nEksen yarýçapý:") cikinti)
      )

      ;2-"Çýkýntý ayarla" seçildi ise
      ((= menu-secimi "Ayarla") ; Dönen deðer "Ayarla" ise
       ; Çýkýntý mesafesini ayarla
       (setq cikinti
        (cond 
          ((getdist (strcat "\nÇýkýntý mesafesi <" (rtos (cond (cikinti) (3))) ">: ")))
          (cikinti) ; Önceki deðer varken Enter
          (3) ; Ýlk kullanýmda Enter
        );cond
       );setq
      )

      ;3-"Geri al" seçildi ise
      ; ---------------------
      ((= menu-secimi "Geri")
       (progn
         (repeat 2 (entdel (entlast))); Son iki çizgiyi sil
         (setq eksensayisi (1- eksensayisi)); Eksen sayýsýný azalt
       )
      )

      ;4-"Çýkýþ" seçildi ise
      ; ------------------
      ((= menu-secimi "Çýkýþ") (setq cikis T))

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
             (EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)) cikinti)
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
(defun EksenCiz (mn r c)  ; Merkez nokta, yarýçap, çýkýntý
  (setq r (+ r c)) ; Çýkýntýyý yarýçapa ekle
  ; Eksenleri çiz
	(vla-startundomark doc)
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
	(vla-endundomark doc)
  (setq eksensayisi (1+ eksensayisi)); Eksen sayýsýný artýr
);defun

; Katman Ekle
; --------------
; Belirtilen ad, çizgi tipi ve çizgi rengi ile yeni bir katman oluþturur.
; katman-adi - Oluþturulacak katmanýn adý.
; cizgi-tipi - Katmana atanacak çizgi tipi.
; cizgi-rengi - Katmana atanacak renk.  
(defun KatmanEkle (katman-adi cizgi-tipi cizgi-rengi) 
  ; Çizgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgi-tipi))  ; Çizgi tipi yoksa
    (progn 
      (command "-linetype" "load" cizgi-tipi "acadiso.lin" "") ; Çizgi tipini yükle
      (if (not (tblsearch "LTYPE" cizgi-tipi)) ; Çizgi tipi yüklenemediyse
        (princ (strcat "\n" cizgi-tipi " çizgi tipi yüklenemedi."))
      );if
    );progn
  );if
  
  ; Katmaný kontrol et
  (if (not (tblsearch "LAYER" katman-adi))  ; Katman yoksa
    (entmake  ; Katman yap
      (list 
        (cons 0 "LAYER") ; Katman
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")
        (cons 70 0) ; Katman durumu ON
        (cons 2 katman-adi) ; Katman adý
        (cons 6 cizgi-tipi) ; Çizgi tipi
        (cons 62 cizgi-rengi) ; Çizgi rengi
        (cons 370 -3) ; Çizgi kalýnlýðý. Default
      );list
    );entmake
  );if
);defun
;--
