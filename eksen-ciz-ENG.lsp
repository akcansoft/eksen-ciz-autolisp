;| DRAW AXIS
Draws vertical and horizontal axes for a circle or arc

12/12/2024
Updated: 19/12/2024

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)

(defun c:DRAWAXIS (/ exitp doc edata ent center-point n ss) 
  ; If an error occurs during execution
  (defun *error* (msg) 
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )
  ; If extension is not set, default = 3
  (if (null extension) (setq extension 3)) ; Extension distance
  (setq doc (vla-get-activedocument (vlax-get-acad-object))) ; Active document
  (vla-startundomark doc) ; Start undo

  ; Add axis layer if it doesn't exist
  (AddLayer "AXIS" "CENTER" 4) ; Layer name, line type, and line color

  ; Infinite loop until exit is selected
  (while (null exitp) 
    ; Options:
    ; 1-Click center point
    ; 2-Set extension
    ; 3-Select object (Default option)
    ; 4-Exit
    (prompt (strcat "\nExtension:" (rtos extension))) ; Extension distance
    (initget "Select Extension eXit") ; Menu options
    (setq center-point ; Center point
          (getpoint 
            "\nSpecify center point [Select Object/set Extension/eXit] <Select Object>: "
          )
    )

    (cond 
      ;1-If center point is clicked
      ;-----------------------------
      ((= 'LIST (type center-point)) ; If returned value is a list
       (DrawAxis center-point (getdist center-point "\nAxis radius:") extension)
      )

      ;2-Set extension
      ((= center-point "Extension") ; If returned value is "Set"
       ; Set extension distance
       (setq extension
        (cond 
          ((getdist           
            (strcat 
              "\nExtension distance <"
              (rtos (cond (extension) (3)))
              ">: "
            ))
          )
          (extension) ; Press Enter to use the previous value
          (3) ; Press Enter for the first use
        );cond
       );setq
      )

      ;3-If Exit is selected
      ; ------------------
      ((= center-point "eXit") (setq exitp T))

      ;4-If Enter is pressed or "Select Object" is chosen
      ;---------------------------------------------
      (T
       (if (setq ss (ssget '((0 . "CIRCLE,ARC"))))  ; Select arc or circle
         ; If selection is made
         ;----------------
         (progn 
           (repeat (setq n (sslength ss))  ; Loop for the number of selected objects
             (setq ent (ssname ss (setq n (1- n))) ; Entity name in selection list
                   edata (entget ent) ; Entity data. DXF info
             )
             ; (DrawAxis centerPoint radius)
             (DrawAxis (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)) extension)
           );repeat
         );progn

         ; If no selection is made
         ;------------------
         (prompt "\n*No circle or arc selected!*")
       );if
      );T
    );cond
  );while
  (princ)
);defun

; Draw axis
; ---------
; Draws vertical and horizontal axes for a circle or arc
; cp: Center point
; r: Radius
; e: Extension distance
(defun DrawAxis (cp r e)  ; Center point, radius, extension
  (setq r (+ r e)) ; Add extension to radius
  ; Draw axes
  ; Loop for 0 and 90 degree angles
  (foreach ang (list 0 (/ pi 2))
    (entmake 
      (list 
        (cons 0 "LINE") ; Entity type
        (cons 8 "AXIS") ; Layer
        (cons 10 (trans (polar cp ang r) 1 0)) ; Start point
        (cons 11 (trans (polar cp (+ pi ang) r) 1 0)) ; End point
      );list
    );entmake
  );foreach
);defun

; Add Layer
; --------------
; Creates a new layer with the specified name, line type, and color.
; layer-name - Name of the layer to create.
; line-type - Line type to assign to the layer.
; line-color - Color to assign to the layer.  
(defun AddLayer (layer-name line-type line-color) 
  ; Check line type
  (if (not (tblsearch "LTYPE" line-type))  ; If line type doesn't exist
    (progn 
      (command "-linetype" "load" line-type "acad.lin" "") ; Load line type
      (if (not (tblsearch "LTYPE" line-type)) ; If line type cannot be loaded
        (princ (strcat "\n" line-type " line type could not be loaded."))
      );if
    );progn
  );if
  
  ; Check layer
  (if (not (tblsearch "LAYER" layer-name))  ; If layer doesn't exist
    (entmake  ; Create layer
      (list 
        (cons 0 "LAYER") ; Layer
        (cons 100 "AcDbSymbolTableRecord")
        (cons 100 "AcDbLayerTableRecord")
        (cons 70 0) ; Layer status ON
        (cons 2 layer-name) ; Layer name
        (cons 6 line-type) ; Line type
        (cons 62 line-color) ; Line color
        (cons 370 -3) ; Lineweight. Default
      );list
    );entmake
  );if
);defun
;--
