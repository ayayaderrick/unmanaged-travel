CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
       entities FOR UPDATE Booking.

    METHODS delete FOR MODIFY
       keys FOR DELETE Booking.

    METHODS read FOR READ
       keys FOR READ Booking RESULT result.

    METHODS rba_Travel FOR READ
       keys_rba FOR READ Booking\_Travel FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
  ENDMETHOD.

ENDCLASS.
