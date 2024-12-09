;| EKSEN ÇÝZ
Çember veya yay'a dikey ve yatay eksenleri çizer
Eksen çizgisi çýkýntý mesafesi 3 alýnmýþtýr.

09/12/2024
Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)

(defun c:EKSEN( / *error* merkez yariCap p1 p2 ent doc cikinti)
  ; Hata olursa
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
	
  (setq
		doc (vla-get-activedocument (vlax-get-acad-object)) ; aktif çizim
		cikinti 3 ; eksen çizgisi çýkýntýsý
	)
  (vla-startundomark doc)

  ; Kullanýcýdan merkez noktasý al veya nesne seç
  (if (setq merkez (getpoint "\nMerkez noktasý belirle veya <Nesne seç>: "))
    ;Merkez noktasý seçildi ise
    (setq yariCap (getdist merkez "\nUzaklýk:"))
    ;Nesne seçilecekse
    (progn
      (while ; Yay veya çember seçildiyse
        (not
          (and
            (setq ent (car (entsel "\nÇember veya yay seç: ")))
            (member (cdr (assoc 0 (entget ent))) '("ARC" "CIRCLE"))
          )
        )
        (prompt "\n*Lütfen çember veya yay nesnesi seçiniz!*")
      )
      (setq merkez (cdr (assoc 10 (entget ent)))) ; Merkez nokta
      (setq yariCap (cdr (assoc 40 (entget ent)))) ; Yarýçap
    )
  )

  ; Eksen katmaný yoksa katmaný yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman adý, çizgi tipi ve çizgi rengi
	
  (setq yariCap (+ yariCap cikinti))

	; Eksenleri çiz
	(foreach aci (list 0 (/ pi 2))
	  (CizgiCiz (polar merkez aci yaricap) (polar merkez (+ pi aci) yaricap))
	)

  (vla-endundomark doc)
  (princ)
)

; Çizgi çiz
; ---------
(defun CizgiCiz (n1 n2)
  (entmake
    (list
      (cons 0 "LINE") ; Nesne tipi
      (cons 8 "EKSEN") ; Katman
      (cons 10 (trans n1 1 0)) ; Baþlangýç noktasý
      (cons 11 (trans n2 1 0)) ; Bitiþ noktasý
    )
  )
)

; Katman oluþtur
; --------------
(defun KatmanYap (katmanAdi cizgiTipi cizgiRengi)
  ; Çizgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgiTipi)) ; Çizgi tipi yoksa
    (progn
      (command "-linetype" "load" cizgiTipi "acad.lin" "") ; Çizgi tipini yükle
      (if (not (tblsearch "LTYPE" cizgiTipi))
        (princ (strcat "\n" cizgiTipi " çizgi tipi yüklenemedi."))
      )
    )
  )
	; Katmaný kontrol et
  (if (not (tblsearch "LAYER" katmanAdi)) ; Katman yoksa
    (entmake ; Katman yap
      (list
				(cons 0 "LAYER")
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")				
				(cons 70 0) ; Katman durumu ON
        (cons 2 katmanAdi) ; Katman adý
        (cons 6 cizgiTipi) ; Çizgi tipi
        (cons 62 cizgiRengi) ; Çizgi rengi
				(cons 370 -3) ; Çizgi kalýnlýðý. Default
      )
    )
  )
)
