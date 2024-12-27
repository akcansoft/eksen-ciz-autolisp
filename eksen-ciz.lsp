;| EKSEN
�ember veya yay'a dikey ve yatay eksenleri �izer
Kullan�c�, nesne se�imi veya merkez noktas� belirleme ile eksen �izebilir.
��k�nt� mesafesi ayarlanabilir.
Son i�lem geri al�nabilir.

12/12/2024 - �lk s�r�m
27/12/2024 - Son g�ncelleme

R13

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)
(setq
  doc (vla-get-activedocument (vlax-get-acad-object)) ; aktif �izim
  cikinti 3 ; ��k�nt� mesafesi
)

(defun c:EKSEN (/ cikis edata ent menu-secimi n ss eksensayisi menutxt) 
  ; �al��ma s�ras�nda hata olursa
  (defun *error* (msg) 
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nHata: " msg)))
    (princ)
  )

  ; Eksen katman� yoksa ekle
  (KatmanEkle "EKSEN" "CENTER" 4) ; Katman ad�, �izgi tipi ve �izgi rengi
  (setq eksensayisi 0) ; Eksen say�s�
  
  ; ��k�� se�ilene kadar sonsuz d�ng�
  (while (null cikis) 
    ; Se�enekler:
		; -----------
    ; 1-Merkez noktas� t�kla
    ; 2-��k�nt� ayarla
    ; 3-Nesne se� (Varsay�lan se�enek)
    ; 4-Geri al
    ; 5-��k��
    (prompt (strcat "\n��k�nt�:" (rtos cikinti))) ; ��k�nt� mesafesi
    (initget "Nesne Ayarla Geri ��k��") ; Men� elemanlar�
    (setq menutxt (strcat "[Nesne se�/��k�nt� Ayarla" (if (> eksensayisi 0) "/Geri al" "") "/��k��]"))
    (setq menu-secimi ; Men� se�imi
          (getpoint (strcat "\nMerkez noktas� belirle " menutxt " <Nesne se�>: "))
    )

    (cond 
      ;1-Merkez noktas� t�kland� ise
      ;-----------------------------
      ((= 'LIST (type menu-secimi)) ; D�nen de�er liste ise
       (EksenCiz menu-secimi (getdist menu-secimi "\nEksen yar��ap�:") cikinti)
      )

      ;2-"��k�nt� ayarla" se�ildi ise
      ((= menu-secimi "Ayarla") ; D�nen de�er "Ayarla" ise
       ; ��k�nt� mesafesini ayarla
       (setq cikinti
        (cond 
          ((getdist (strcat "\n��k�nt� mesafesi <" (rtos (cond (cikinti) (3))) ">: ")))
          (cikinti) ; �nceki de�er varken Enter
          (3) ; �lk kullan�mda Enter
        );cond
       );setq
      )

      ;3-"Geri al" se�ildi ise
      ; ---------------------
      ((= menu-secimi "Geri")
       (progn
         (repeat 2 (entdel (entlast))); Son iki �izgiyi sil
         (setq eksensayisi (1- eksensayisi)); Eksen say�s�n� azalt
       )
      )

      ;4-"��k��" se�ildi ise
      ; ------------------
      ((= menu-secimi "��k��") (setq cikis T))

      ;5-"Nesne se�" se�ildi veya Enter'e bas�ld� ise
      ;---------------------------------------------
      (T
       (if (setq ss (ssget '((0 . "CIRCLE,ARC"))))  ; Yay veya �ember se�
         ;se�im yap�ld�ysa
         ;----------------
         (progn 
           (repeat (setq n (sslength ss))  ; Se�ili nesne say�s� kadar d�ng�
             (setq ent (ssname ss (setq n (1- n))) ; se�im listesindeki varl�k ad�
                   edata (entget ent) ; Varl�k verileri. DXF bilgiler
             )
             (EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)) cikinti)
           );repeat
         );progn

         ;se�im yap�lmad�ysa
         ;------------------
         (prompt "\n*�ember veya yay se�ilmedi!*")
       );if
      );T
    );cond
  );while
  (princ)
);defun

; Eksen �iz
; ---------
; �ember veya yay'a dikey ve yatay eksenleri �izer
; mn: Merkez noktas�
; r: Yar��ap
; c: ��k�nt� mesafesi
(defun EksenCiz (mn r c)  ; Merkez nokta, yar��ap, ��k�nt�
  (setq r (+ r c)) ; ��k�nt�y� yar��apa ekle
  ; Eksenleri �iz
	(vla-startundomark doc)
  ; 0 ve 90 derece a��lar� i�in d�ng�
  (foreach aci (list 0 (/ pi 2))
    (entmake 
      (list 
        (cons 0 "LINE") ; Nesne tipi
        (cons 8 "EKSEN") ; Katman
        (cons 10 (trans (polar mn aci r) 1 0)) ; Ba�lang�� noktas�
        (cons 11 (trans (polar mn (+ pi aci) r) 1 0)) ; Biti� noktas�
      );list
    );entmake
  );foreach
	(vla-endundomark doc)
  (setq eksensayisi (1+ eksensayisi)); Eksen say�s�n� art�r
);defun

; Katman Ekle
; --------------
; Belirtilen ad, �izgi tipi ve �izgi rengi ile yeni bir katman olu�turur.
; katman-adi - Olu�turulacak katman�n ad�.
; cizgi-tipi - Katmana atanacak �izgi tipi.
; cizgi-rengi - Katmana atanacak renk.  
(defun KatmanEkle (katman-adi cizgi-tipi cizgi-rengi) 
  ; �izgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgi-tipi))  ; �izgi tipi yoksa
    (progn 
      (command "-linetype" "load" cizgi-tipi "acadiso.lin" "") ; �izgi tipini y�kle
      (if (not (tblsearch "LTYPE" cizgi-tipi)) ; �izgi tipi y�klenemediyse
        (princ (strcat "\n" cizgi-tipi " �izgi tipi y�klenemedi."))
      );if
    );progn
  );if
  
  ; Katman� kontrol et
  (if (not (tblsearch "LAYER" katman-adi))  ; Katman yoksa
    (entmake  ; Katman yap
      (list 
        (cons 0 "LAYER") ; Katman
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")
        (cons 70 0) ; Katman durumu ON
        (cons 2 katman-adi) ; Katman ad�
        (cons 6 cizgi-tipi) ; �izgi tipi
        (cons 62 cizgi-rengi) ; �izgi rengi
        (cons 370 -3) ; �izgi kal�nl���. Default
      );list
    );entmake
  );if
);defun
;--
