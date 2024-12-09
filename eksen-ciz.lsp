;| EKSEN ÇİZ
Çember veya yay'a dikey ve yatay eksenleri çizer
Eksen çizgisi çıkıntı mesafesi 3 alınmıştır.

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
		cikinti 3 ; eksen çizgisi çıkıntısı
	)
  (vla-startundomark doc)

  ; Kullanıcıdan merkez noktası al veya nesne seç
  (if (setq merkez (getpoint "\nMerkez noktası belirle veya <Nesne seç>: "))
    ;Merkez noktası seçildi ise
    (setq yariCap (getdist merkez "\nUzaklık:"))
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
      (setq yariCap (cdr (assoc 40 (entget ent)))) ; Yarıçap
    )
  )

  ; Eksen katmanı yoksa katmanı yap
  (KatmanYap "EKSEN" "CENTER2" 4) ; Katman adı, çizgi tipi ve çizgi rengi
	
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
      (cons 10 (trans n1 1 0)) ; Başlangıç noktası
      (cons 11 (trans n2 1 0)) ; Bitiş noktası
    )
  )
)

; Katman oluştur
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
	; Katmanı kontrol et
  (if (not (tblsearch "LAYER" katmanAdi)) ; Katman yoksa
    (entmake ; Katman yap
      (list
				(cons 0 "LAYER")
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")				
				(cons 70 0) ; Katman durumu ON
        (cons 2 katmanAdi) ; Katman adı
        (cons 6 cizgiTipi) ; Çizgi tipi
        (cons 62 cizgiRengi) ; Çizgi rengi
				(cons 370 -3) ; Çizgi kalınlığı. Default
      )
    )
  )
)
