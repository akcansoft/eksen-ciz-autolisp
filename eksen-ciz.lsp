;| EKSEN ÇÝZ
Çember veya yay'a dikey ve yatay eksenleri çizer
Eksen çizgisi çýkýntý mesafesi 3 alýnmýþtýr.

12/12/2024
Güncelleme: 18/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

; YAPILACAK
; - Menüde "Çýkýntý ayarla" seçeneði

(vl-load-com)

(defun c:EKSEN( / cikis doc edata ent merkeznokta n ss)
  ; Hata olursa
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
	
  (setq doc (vla-get-activedocument (vlax-get-acad-object))) ; aktif çizim
  (vla-startundomark doc)

  ; Eksen katmaný yoksa katmaný yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman adý, çizgi tipi ve çizgi rengi

	; Çýkýþ seçilene kadar sonsuz döngü
	(while (null cikis)
  	; Seçenekler:
  	; 1-Merkez noktasý týkla
		; 2-Nesne seç (Varsayýlan seçenek)
		; 3-Çýkýþ
		(initget "Nesne Çýkýþ") ; Menü elemanlarý
		(setq merkezNokta (getpoint "\nMerkez noktasý belirle [Nesne seç/Çýkýþ] <Nesne seç>: "))

		(cond
			;1-Merkez noktasý týklandý ise
			;-----------------------------
			((= 'LIST (type merkezNokta))
			 (EksenCiz merkezNokta (getdist merkezNokta "\nEksen yarýçapý:"))
			)
			
			;2-Çýkýþ seçildi ise
			; ------------------
			((= merkezNokta "Çýkýþ") (setq cikis T))
			
			;3-Enter'e basýldý veya "Nesne seç" seçildi ise
			;---------------------------------------------
			(T 
	      (if (setq ss (ssget '((0 . "CIRCLE,ARC")))) ; Yay veya çember seç
					;seçim yapýldýysa
					;----------------
					(progn
						(repeat (setq n (sslength ss)) ; Seçili nesne sayýsý kadar döngü
							(setq
			          ent (ssname ss (setq n (1- n))) ; seçim listesindeki varlýk adý
			          edata (entget ent) ; Varlýk verileri. DXF bilgiler
			        )
							; (EksenCiz merkezNokta yariCap)
							(EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)))
						);repeat
					 );progn
					
					;seçim yapýlmadýysa
					;------------------
					(prompt "\n*Çember veya yay seçilmedi!*")
	      ) ;if
			) ;T
		) ;cond
	) ;while
	(princ)
) ;defun

; Çizgi çiz
; ---------
(defun EksenCiz (mn r) ; merkeznokta, yaricap
	(setq r (+ r 3)) ; Çýkýntý = 3
	; Eksenleri çiz
	(foreach aci (list 0 (/ pi 2)) ; 0° ve 90°
	  (entmake
	    (list
	      (cons 0 "LINE") ; Nesne tipi
	      (cons 8 "EKSEN") ; Katman
	      (cons 10 (trans (polar mn aci r) 1 0)) ; Baþlangýç noktasý
	      (cons 11 (trans (polar mn (+ pi aci) r) 1 0)) ; Bitiþ noktasý
	    ) ;list
		) ;entmake
	) ;foreach
) ;defun

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
;---