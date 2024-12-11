;| EKSEN ��Z
�ember veya yay'a dikey ve yatay eksenleri �izer
Eksen �izgisi ��k�nt� mesafesi 3 al�nm��t�r.

09/12/2024
G�ncelleme: 11/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)

(defun c:EKSEN( / *error* merkezNokta yariCap p1 p2 ent doc cikinti cikis)
  ; Hata olursa
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
	
  (setq
		doc (vla-get-activedocument (vlax-get-acad-object)) ; aktif �izim
		cikinti 3 ; eksen �izgisi ��k�nt�s�
	)
  (vla-startundomark doc)

  ; Eksen katman� yoksa katman� yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman ad�, �izgi tipi ve �izgi rengi

	; ��k�� se�ilene kadar sonsuz d�ng�
	(while (null cikis)
  	; Se�enekler:
  	; 1-Merkez noktas� t�kla
		; 2-Nesne se� (Varsay�lan se�enek)
		; 3-��k��
		(initget "Nesne ��k��")
		(setq merkezNokta (getpoint "\nMerkez noktas� belirle [Nesne se�/��k��] <Nesne se�>: "))

		(cond
			;1-Merkez noktas� t�kland� ise
			;--------------------------
			((= 'LIST (type merkezNokta))
			 (setq yariCap (getdist merkezNokta "\nUzakl�k:"))
			)
			
			;2-��k�� se�ildi ise
			; ------------------
			((= merkezNokta "��k��") (setq cikis T))
			
			;3-Enter'e bas�ld� veya "Nesne se�" se�ildi ise
			;---------------------------------------------
			(T 
	      (while ; Yay veya �ember se�ene kadar d�ng�
	        (not
	          (and
	            (setq ent (car (entsel "\n�ember veya yay se�: ")))
	            (member (cdr (assoc 0 (entget ent))) '("ARC" "CIRCLE"))
	          )
	        )
	        (prompt "\n*L�tfen �ember veya yay se�iniz!*")
	      )
	      (setq
					merkezNokta (trans (cdr (assoc 10 (entget ent))) ent 1) ; Nesne merkez noktas�
					yariCap (cdr (assoc 40 (entget ent))) ; Nesne yar��ap�
				)
			) ; T
		) ; cond
		
		(if (/= merkezNokta "��k��")
			(progn
				(setq yariCap (+ yariCap cikinti))
				; Eksenleri �iz
				(foreach aci (list 0 (/ pi 2))
					(CizgiCiz (polar merkezNokta aci yaricap) (polar merkezNokta (+ pi aci) yaricap))
				) ; foreach
			) ; progn
		) ;if
	) ; while
	(princ)
) ; defun

; �izgi �iz
; ---------
(defun CizgiCiz (n1 n2)
  (entmake
    (list
      (cons 0 "LINE") ; Nesne tipi
      (cons 8 "EKSEN") ; Katman
      (cons 10 (trans n1 1 0)) ; Ba�lang�� noktas�
      (cons 11 (trans n2 1 0)) ; Biti� noktas�
    )
  )
)

; Katman olu�tur
; --------------
(defun KatmanYap (katmanAdi cizgiTipi cizgiRengi)
  ; �izgi tipini kontrol et
  (if (not (tblsearch "LTYPE" cizgiTipi)) ; �izgi tipi yoksa
    (progn
      (command "-linetype" "load" cizgiTipi "acad.lin" "") ; �izgi tipini y�kle
      (if (not (tblsearch "LTYPE" cizgiTipi))
        (princ (strcat "\n" cizgiTipi " �izgi tipi y�klenemedi."))
      )
    )
  )
	; Katman� kontrol et
  (if (not (tblsearch "LAYER" katmanAdi)) ; Katman yoksa
    (entmake ; Katman yap
      (list
				(cons 0 "LAYER")
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")				
				(cons 70 0) ; Katman durumu ON
        (cons 2 katmanAdi) ; Katman ad�
        (cons 6 cizgiTipi) ; �izgi tipi
        (cons 62 cizgiRengi) ; �izgi rengi
				(cons 370 -3) ; �izgi kal�nl���. Default
      )
    )
  )
)
;---