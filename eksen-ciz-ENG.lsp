;|
DRAW AXIS
Draws vertical and horizontal axes on a circle or arc.
The user can draw an axis by selecting an object or defining a center point.
The Extension distance can be adjusted.
The last action can be undone.

12/12/2024 - First version
24/12/2024 - Last update

Mesut Akcan
makcan@gmail.com

https://www.youtube.com/mesutakcan
https://mesutakcan.blogspot.com
|;

(vl-load-com)
(setq
  doc (vla-get-activedocument (vlax-get-acad-object)) ; active drawing
  extension 3 ; Extension distance
)

(defun c:DRAWAXIS (/ exitp edata ent menu-selection n ss) 
  ; If an error occurs during execution
  (defun *error* (msg) 
    (if doc (vla-endundomark doc))
    (if msg (princ (strcat "\nError: " msg)))
    (princ)
  )

  ; Add axis layer if it doesn't exist
  (AddLayer "AXIS" "CENTER" 4) ; Layer name, line type, and line color

  ; Infinite loop until exit is selected
  (while (null exitp) 
    ; Options:
    ; -----------
    ; 1-Click center point
    ; 2-Set extension distance
    ; 3-Select object (Default option)
    ; 4-Undo
    ; 5-Exit
    (prompt (strcat "\nExtension:" (rtos extension))) ; Extension distance
    (initget "Select Extension Undo eXit") ; Menu items
    (setq menu-selection ; Menu selection
          (getpoint 
            "\nSpecify center point [Select object/Extension/Undo/eXit] <Select object>: "
          )
    )

    (cond 
      ;1-If center point was clicked
      ;-----------------------------
      ((= 'LIST (type menu-selection)) ; If returned value is a list
       (DrawAxis menu-selection (getdist menu-selection "\nAxis radius:") extension)
      )

      ;2-If "Set Extension" was selected
      ((= menu-selection "Extension") ; If returned value is "Extension"
       ; Set the Extension distance
       (setq extension
        (cond 
          ((getdist (strcat "\nExtension distance <" (rtos (cond (extension) (3))) ">: ")))
          (extension) ; Enter when there is a previous value
          (3) ; Enter first time
        );cond
       );setq
      )

      ;3-If "Undo" was selected
      ; ---------------------
      ((= menu-selection "Undo")
       (command "._UNDO" "1")
      )

      ;4-If "Exit" was selected
      ; ------------------
      ((= menu-selection "eXit") (setq exitp T))

      ;5-If "Select object" was selected or Enter was pressed
      ;---------------------------------------------
      (T
       (if (setq ss (ssget '((0 . "CIRCLE,ARC"))))  ; Select arc or circle
         ; If a selection was made
         ;----------------
         (progn 
           (repeat (setq n (sslength ss))  ; Loop for the number of selected objects
             (setq ent (ssname ss (setq n (1- n))) ; Name of the entity in selection list
                   edata (entget ent) ; Entity data. DXF information
             )
             (DrawAxis (trans (cdr (assoc 10 edata)) ent 1) (cdr (assoc 40 edata)) extension)
           );repeat
         );progn

         ; If no selection was made
         ;------------------
         (prompt "\n*Circle or arc not selected!*")
       );if
      );T
    );cond
  );while
  (princ)
);defun

; Draw Axis
; ---------
; Draws vertical and horizontal axes on a circle or arc
; mn: Center point
; r: Radius
; c: Extension distance
(defun DrawAxis (mn r c)  ; Center point, radius, Extension
  (setq r (+ r c)) ; Add Extension to radius
  ; Draw axes
  (vla-startundomark doc)
  ; Loop for 0 and 90 degree angles
  (foreach ang (list 0 (/ pi 2))
    (entmake 
      (list 
        (cons 0 "LINE") ; Object type
        (cons 8 "AXIS") ; Layer
        (cons 10 (trans (polar mn ang r) 1 0)) ; Start point
        (cons 11 (trans (polar mn (+ pi ang) r) 1 0)) ; End point
      );list
    );entmake
  );foreach
  (vla-endundomark doc)
);defun

; Add Layer
; --------------
; Creates a new layer with the specified name, line type, and line color.
; layer-name - Name of the layer to be created.
; line-type - Line type to be assigned to the layer.
; line-color - Color to be assigned to the layer.  
(defun AddLayer (layer-name line-type line-color) 
  ; Check line type
  (if (not (tblsearch "LTYPE" line-type))  ; If line type doesn't exist
    (progn 
      (command "-linetype" "load" line-type "acad.lin" "") ; Load line type
      (if (not (tblsearch "LTYPE" line-type)) ; If line type couldn't be loaded
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
        (cons 70 0) ; Layer state ON
        (cons 2 layer-name) ; Layer name
        (cons 6 line-type) ; Line type
        (cons 62 line-color) ; Line color
        (cons 370 -3) ; Line thickness. Default
      );list
    );entmake
  );if
);defun
;--