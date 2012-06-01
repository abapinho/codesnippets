REPORT zzz_abapinho_f1_selscreen.

PARAMETERS: p_name1(10) TYPE c.
PARAMETERS: p_name2(10) TYPE c.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_name1.

  CALL FUNCTION 'DSYS_SHOW_FOR_F1HELP'
    EXPORTING
      dokclass         = 'TX'
      doklangu         = sy-langu
      dokname          = 'ZZZ_ABAPINHO_UNAME'
      doktitle         = 'Título da coisa'
    EXCEPTIONS
      class_unknown    = 1
      object_not_found = 2
      OTHERS           = 3.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_name2.

  MESSAGE i052(00).