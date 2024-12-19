;| EKSEN ÇÝZ
Çember veya yay'a dikey ve yatay eksenleri çizer

12/12/2024
Güncelleme: 19/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)

(defun c:EKSEN (/ cikis doc edata ent merkez-nokta n ss) 
  ; Çalýþma sýrasýnda hata olursa
  (defun *error* (msg) 
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nHata: " msg)))
    (princ)
  )
  ; Çýkýntý ayarlanmamýþsa = 3
  (if (null cikinti) (setq cikinti 3)) ; Çýkýntý mesafesi
  (setq doc (vla-get-activedocument (vlax-get-acad-object))) ; aktif çizim
  (vla-startundomark doc) ; Geri alma baþlat

  ; Eksen katmaný yoksa ekle
  (KatmanEkle "EKSEN" "CENTER" 4) ; Katman adý, çizgi tipi ve çizgi rengi

  ; Çýkýþ seçilene kadar sonsuz döngü
  (while (null cikis) 
    ; Seçenekler:
    ; 1-Merkez noktasý týkla
    ; 2-Çýkýntý ayarla
    ; 3-Nesne seç (Varsayýlan seçenek)
    ; 4-Çýkýþ
    (prompt (strcat "\nÇýkýntý:" (rtos cikinti))) ; Çýkýntý mesafesi
    (initget "Nesne Ayarla Çýkýþ") ; Menü elemanlarý
    (setq merkez-nokta ; Merkez noktasý
          (getpoint 
            "\nMerkez noktasý belirle [Nesne seç/çýkýntý Ayarla/Çýkýþ] <Nesne seç>: "
          )
    )

    (cond 
      ;1-Merkez noktasý týklandý ise
      ;-----------------------------
      ((= 'LIST (type merkez-nokta)) ; Dönen deðer liste ise
       (EksenCiz merkez-nokta (getdist merkez-nokta "\nEksen yarýçapý:") cikinti)
      )

      ;2-Çýkýntý ayarla
      ((= merkez-nokta "Ayarla") ; Dönen deðer "Ayarla" ise
       ; Çýkýntý mesafesini ayarla
       (setq cikinti
        (cond 
          ((getdist           
            (strcat 
              "\nÇýkýntý mesafesi <"
              (rtos (cond (cikinti) (3)))
              ">: "
            ))
          )
          (cikinti) ; Önceki deðer varsa Enter
          (3) ; Ýlk kullanýmda Enter
        );cond
       );setq
      )

      ;3-Çýkýþ seçildi ise
      ; ------------------
      ((= merkez-nokta "Çýkýþ") (setq cikis T))

      ;4-Enter'e basýldý veya "Nesne seç" seçildi ise
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
             ; (EksenCiz merkezNokta yariCap)
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
      (command "-linetype" "load" cizgi-tipi "acad.lin" "") ; Çizgi tipini yükle
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
