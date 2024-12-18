;| EKSEN ��Z
�ember veya yay'a dikey ve yatay eksenleri �izer
Eksen �izgisi ��k�nt� mesafesi 3 al�nm��t�r.

12/12/2024
G�ncelleme: 18/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

; YAPILACAK
; - Men�de "��k�nt� ayarla" se�ene�i

(vl-load-com)

(defun c:EKSEN( / cikis doc edata ent merkeznokta n ss)
  ; Hata olursa
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
	
  (setq doc (vla-get-activedocument (vlax-get-acad-object))) ; aktif �izim
  (vla-startundomark doc)

  ; Eksen katman� yoksa katman� yap
  (KatmanYap "EKSEN" "CENTER" 4) ; Katman ad�, �izgi tipi ve �izgi rengi

	; ��k�� se�ilene kadar sonsuz d�ng�
	(while (null cikis)
  	; Se�enekler:
  	; 1-Merkez noktas� t�kla
		; 2-Nesne se� (Varsay�lan se�enek)
		; 3-��k��
		(initget "Nesne ��k��") ; Men� elemanlar�
		(setq merkezNokta (getpoint "\nMerkez noktas� belirle [Nesne se�/��k��] <Nesne se�>: "))

		(cond
			;1-Merkez noktas� t�kland� ise
			;-----------------------------
			((= 'LIST (type merkezNokta))
			 (EksenCiz merkezNokta (getdist merkezNokta "\nEksen yar��ap�:"))
			)
			
			;2-��k�� se�ildi ise
			; ------------------
			((= merkezNokta "��k��") (setq cikis T))
			
			;3-Enter'e bas�ld� veya "Nesne se�" se�ildi ise
			;---------------------------------------------
			(T 
	      (if (setq ss (ssget '((0 . "CIRCLE,ARC")))) ; Yay veya �ember se�
					;se�im yap�ld�ysa
					;----------------
					(progn
						(repeat (setq n (sslength ss)) ; Se�ili nesne say�s� kadar d�ng�
							(setq
			          ent (ssname ss (setq n (1- n))) ; se�im listesindeki varl�k ad�
			          edata (entget ent) ; Varl�k verileri. DXF bilgiler
			        )
							; (EksenCiz merkezNokta yariCap)
							(EksenCiz (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)))
						);repeat
					 );progn
					
					;se�im yap�lmad�ysa
					;------------------
					(prompt "\n*�ember veya yay se�ilmedi!*")
	      ) ;if
			) ;T
		) ;cond
	) ;while
	(princ)
) ;defun

; �izgi �iz
; ---------
(defun EksenCiz (mn r) ; merkeznokta, yaricap
	(setq r (+ r 3)) ; ��k�nt� = 3
	; Eksenleri �iz
	(foreach aci (list 0 (/ pi 2)) ; 0� ve 90�
	  (entmake
	    (list
	      (cons 0 "LINE") ; Nesne tipi
	      (cons 8 "EKSEN") ; Katman
	      (cons 10 (trans (polar mn aci r) 1 0)) ; Ba�lang�� noktas�
	      (cons 11 (trans (polar mn (+ pi aci) r) 1 0)) ; Biti� noktas�
	    ) ;list
		) ;entmake
	) ;foreach
) ;defun

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