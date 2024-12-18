;| EKSEN CIZ
Cember veya yay'a dikey ve yatay eksenleri cizer
Eksen cizgisi cikinti mesafesi 3 alinmistir.

12/12/2024
Guncelleme: 18/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

; YAPILACAK
; - Menude "Cikinti ayarla" secenegi

(vl-load-com)

(defun c:EKSEN( / cikis doc edata ent merkeznokta n ss)
  ; Hata olursa
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
    
  (setq doc (vla-get-activedocument (vlax-get-acad-object))) ; aktif cizim
  (vla-startundomark doc)

  ; Eksen katmani yoksa katmani yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman adi, cizgi tipi ve cizgi rengi

    ; Cikis secilene kadar sonsuz dongu
    (while (null cikis)
      ; Secenekler:
      ; 1-Merkez noktasi tikla
        ; 2-Nesne sec (Varsayilan secenek)
        ; 3-Cikis
        (initget "Nesne Cikis") ; Menu elemanlari
        (setq merkezNokta (getpoint "\nMerkez noktasi belirle [Nesne sec/Cikis] <Nesne sec>: "))

        (cond
            ;1-Merkez noktasi tiklandi ise
            ;-----------------------------
            ((= 'LIST (type merkezNokta))
             (EksenCiz merkezNokta (getdist merkezNokta "\nEksen yaricapi:"))
            )
            
            ;2-Cikis secildi ise
            ; ------------------
            ((= merkezNokta "Cikis") (setq cikis T))
            
            ;3-Enter'e basildi veya "Nesne sec" secildi ise
            ;---------------------------------------------
            (T 
          (if (setq ss (ssget '((0 . "CIRCLE,ARC")))) ; Yay veya cember sec
                    ;secim yapildiysa
                    ;----------------
                    (progn
                        (repeat (setq n (sslength ss)) ; Secili nesne sayisi kadar dongu
                            (setq
                      ent (ssname ss (setq n (1- n))) ; secim listesindeki varlik adi
                      edata (entget ent) ; Varlik verileri. DXF bilgiler
                    )
                            ; (EksenCiz merkezNokta yariCap)
                            (EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)))
                        );repeat
                     );progn
                    
                    ;secim yapilmadiysa
                    ;------------------
                    (prompt "\n*Cember veya yay secilmedi!*")
          ) ;if
            ) ;T
        ) ;cond
    ) ;while
    (princ)
) ;defun

; Cizgi ciz
; ---------
(defun EksenCiz (mn r) ; merkeznokta, yaricap
    (setq r (+ r 3)) ; Cikinti = 3
    ; Eksenleri ciz
    (foreach aci (list 0 (/ pi 2)) ; 0° ve 90°
      (entmake
        (list
          (cons 0 "LINE") ; Nesne tipi
          (cons 8 "EKSEN") ; Katman
          (cons 10 (trans (polar mn aci r) 1 0)) ; Baslangic noktasi
          (cons 11 (trans (polar mn (+ pi aci) r) 1 0)) ; Bitis noktasi
        ) ;list
        ) ;entmake
    ) ;foreach
) ;defun

; Katman olustur
; --------------
(defun KatmanYap (katmanAdi cizgiTipi cizgiRengi)
  ; Cizgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgiTipi)) ; Cizgi tipi yoksa
    (progn
      (command "-linetype" "load" cizgiTipi "acad.lin" "") ; Cizgi tipini yukle
      (if (not (tblsearch "LTYPE" cizgiTipi))
        (princ (strcat "\n" cizgiTipi " cizgi tipi yuklenemedi."))
      )
    )
  )
    ; Katmani kontrol et
  (if (not (tblsearch "LAYER" katmanAdi)) ; Katman yoksa
    (entmake ; Katman yap
      (list
                (cons 0 "LAYER")
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")                
                (cons 70 0) ; Katman durumu ON
        (cons 2 katmanAdi) ; Katman adi
        (cons 6 cizgiTipi) ; Cizgi tipi
        (cons 62 cizgiRengi) ; Cizgi rengi
                (cons 370 -3) ; Cizgi kalinligi. Default
      )
    )
  )
)
;---