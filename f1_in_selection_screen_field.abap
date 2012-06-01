REPORT zzz_abapinho_f1_selscreen.

PARAMETERS: p_uname1 TYPE syuname.
PARAMETERS: p_uname2 TYPE syuname.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_uname1.

  CALL FUNCTION 'DSYS_SHOW_FOR_F1HELP'
    EXPORTING
      dokclass         = 'TX'
      doklangu         = sy-langu
      dokname          = 'ZZZ_ABAPINHO_UNAME1_F1'
*      doktitle         = 'Aqui metes um título opcional'
    EXCEPTIONS
      class_unknown    = 1
      object_not_found = 2
      OTHERS           = 3.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_uname2.

  MESSAGE i052(00).