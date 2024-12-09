;| EKSEN ��Z
�ember veya yay'a dikey ve yatay eksenleri �izer
Eksen �izgisi ��k�nt� mesafesi 3 al�nm��t�r.

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
		doc (vla-get-activedocument (vlax-get-acad-object)) ; aktif �izim
		cikinti 3 ; eksen �izgisi ��k�nt�s�
	)
  (vla-startundomark doc)

  ; Kullan�c�dan merkez noktas� al veya nesne se�
  (if (setq merkez (getpoint "\nMerkez noktas� belirle veya <Nesne se�>: "))
    ;Merkez noktas� se�ildi ise
    (setq yariCap (getdist merkez "\nUzakl�k:"))
    ;Nesne se�ilecekse
    (progn
      (while ; Yay veya �ember se�ildiyse
        (not
          (and
            (setq ent (car (entsel "\n�ember veya yay se�: ")))
            (member (cdr (assoc 0 (entget ent))) '("ARC" "CIRCLE"))
          )
        )
        (prompt "\n*L�tfen �ember veya yay nesnesi se�iniz!*")
      )
      (setq merkez (cdr (assoc 10 (entget ent)))) ; Merkez nokta
      (setq yariCap (cdr (assoc 40 (entget ent)))) ; Yar��ap
    )
  )

  ; Eksen katman� yoksa katman� yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman ad�, �izgi tipi ve �izgi rengi
	
  (setq yariCap (+ yariCap cikinti))

	; Eksenleri �iz
	(foreach aci (list 0 (/ pi 2))
	  (CizgiCiz (polar merkez aci yaricap) (polar merkez (+ pi aci) yaricap))
	)

  (vla-endundomark doc)
  (princ)
)

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
