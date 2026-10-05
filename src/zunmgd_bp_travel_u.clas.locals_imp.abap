CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES tt_travel_failed    TYPE TABLE FOR FAILED   ZUMNGD_I_Travel_U.
    TYPES tt_travel_reported  TYPE TABLE FOR REPORTED ZUMNGD_I_Travel_U.
    TYPES tt_booking_failed   TYPE TABLE FOR FAILED   ZUMNGD_I_Booking_U.
    TYPES tt_booking_reported TYPE TABLE FOR REPORTED ZUMNGD_I_Booking_U.

    METHODS create FOR MODIFY
       entities FOR CREATE Travel.

    METHODS update FOR MODIFY
       entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
       keys FOR DELETE Travel.

    METHODS read FOR READ
       keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
       keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
       entities_cba FOR CREATE Travel\_Booking.

    METHODS map_messages
      IMPORTING
        cid          TYPE string         OPTIONAL
        travel_id    TYPE /dmo/travel_id OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_travel_failed
        reported     TYPE tt_travel_reported.

    METHODS map_messages_assoc_to_booking
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool       DEFAULT  abap_false
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_booking_failed
        reported     TYPE tt_booking_reported.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD create.
    DATA: messages   TYPE /dmo/t_message,
          travel_in  TYPE /dmo/travel,
          travel_out TYPE /dmo/travel.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_create>).

      travel_in = CORRESPONDING #( <travel_create> MAPPING FROM ENTITY USING CONTROL ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( travel_in )
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = travel_out
          et_messages       = messages.

      map_messages(
          EXPORTING
            cid       = <travel_create>-%cid
            messages  = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

      IF failed_added = abap_false.
        INSERT VALUE #(
            %cid     = <travel_create>-%cid
            travelid = travel_out-travel_id )
          INTO TABLE mapped-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.
    DATA: messages TYPE /dmo/t_message,
          travel   TYPE /dmo/travel,
          travelx  TYPE /dmo/s_travel_inx. "refers to x structure (> BAPIs)

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).

      travel = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      travelx-travel_id = <travel_update>-TravelID.
      travelx-_intx     = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( travel )
          is_travelx  = travelx
        IMPORTING
          et_messages = messages.

      map_messages(
          EXPORTING
            cid       = <travel_update>-%cid_ref
            travel_id = <travel_update>-travelid
            messages  = messages
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    DATA: messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_delete>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <travel_delete>-travelid
        IMPORTING
          et_messages  = messages.

      map_messages(
          EXPORTING
            cid       = <travel_delete>-%cid_ref
            travel_id = <travel_delete>-travelid
            messages  = messages
          CHANGING
            failed    = failed-travel
            reported  = reported-travel
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    DATA: travel_out TYPE /dmo/travel,
          messages   TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_to_read>) GROUP BY <travel_to_read>-%tky.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <travel_to_read>-travelid
        IMPORTING
          es_travel    = travel_out
          et_messages  = messages.

      map_messages(
          EXPORTING
            travel_id        = <travel_to_read>-TravelID
            messages         = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-travel
            reported         = reported-travel
        ).

      IF failed_added = abap_false.
        INSERT CORRESPONDING #( travel_out MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Booking.
  ENDMETHOD.

  METHOD cba_Booking.

    DATA: messages        TYPE /dmo/t_message,
          booking_old     TYPE /dmo/t_booking,
          booking         TYPE /dmo/booking,
          last_booking_id TYPE /dmo/booking_id VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(travelid) = <travel>-travelid.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = booking_old
          et_messages  = messages.

      map_messages(
          EXPORTING
            cid          = <travel>-%cid_ref
            travel_id    = <travel>-TravelID
            messages     = messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed       = failed-travel
            reported     = reported-travel
        ).

      IF failed_added = abap_true.
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking>).
          map_messages_assoc_to_booking(
            EXPORTING
              cid          = <booking>-%cid
              is_dependend = abap_true
              messages     = messages
            CHANGING
              failed       = failed-booking
              reported     = reported-booking
          ).
        ENDLOOP.

      ELSE.

        " Set the last_booking_id to the highest value of booking_old booking_id or initial value if none exist
        last_booking_id = VALUE #( booking_old[ lines( booking_old ) ]-booking_id OPTIONAL ).

        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_create>).

          booking = CORRESPONDING #( <booking_create> MAPPING FROM ENTITY USING CONTROL ) .

          last_booking_id += 1.
          booking-booking_id = last_booking_id.

          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = travelid )
              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx(
                (
                  booking_id  = booking-booking_id
                  action_code = /dmo/if_flight_legacy=>action_code-create
                )
              )
            IMPORTING
              et_messages = messages.

          map_messages_assoc_to_booking(
              EXPORTING
                cid          = <booking_create>-%cid
                messages     = messages
              IMPORTING
                failed_added = failed_added
              CHANGING
                failed       = failed-booking
                reported     = reported-booking
            ).

          IF failed_added = abap_false.
            INSERT
              VALUE #(
                %cid      = <booking_create>-%cid
                travelid  = travelid
                bookingid = booking-booking_id
              ) INTO TABLE mapped-booking.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF ( message-msgty = 'E' OR message-msgty = 'A' ) AND
         ( NOT line_exists( failed[ KEY entity COMPONENTS %cid = cid  TravelID = travel_id ] ) ).
        APPEND VALUE #( %cid        = cid
                        travelid    = travel_id
                        %fail-cause = /dmo/cl_travel_auxiliary=>get_cause_from_message(
                                        msgid = message-msgid
                                        msgno = message-msgno
                                      ) )
               TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = message-msgid
                                        number   = message-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = message-msgv1
                                        v2       = message-msgv2
                                        v3       = message-msgv3
                                        v4       = message-msgv4 )
                      %cid          = cid
                      TravelID      = travel_id )
             TO reported.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_messages_assoc_to_booking.
    ASSERT cid IS NOT INITIAL.  "In a create case, the %cid has to be present
    failed_added = abap_false.
    LOOP AT messages INTO DATA(message).
      IF ( message-msgty = 'E' OR message-msgty = 'A' ) AND
         ( NOT line_exists( failed[ KEY cid COMPONENTS %cid = cid ] ) ).
        APPEND VALUE #( %cid        = cid
                        %fail-cause = /dmo/cl_travel_auxiliary=>get_cause_from_message(
                                        msgid = message-msgid
                                        msgno = message-msgno
                                        is_dependend = is_dependend
                                      ) )
               TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = message-msgid
                                        number   = message-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = message-msgv1
                                        v2       = message-msgv2
                                        v3       = message-msgv3
                                        v4       = message-msgv4 )
                      %cid          = cid )
             TO reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZUMNGD_I_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZUMNGD_I_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.

    DATA: travel_mapping       TYPE /dmo/if_flight_legacy=>tt_ln_travel_mapping,
          booking_mapping      TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping,
          bookingsuppl_mapping TYPE /dmo/if_flight_legacy=>tt_ln_bookingsuppl_mapping.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping       = travel_mapping
        et_booking_mapping      = booking_mapping
        et_bookingsuppl_mapping = bookingsuppl_mapping.

    mapped-travel = VALUE #( FOR travel IN travel_mapping ( %tmp = VALUE #( TravelID = travel-preliminary-travel_id )
                                                                            TravelID = travel-final-travel_id ) ).

    mapped-booking = VALUE #( FOR booking IN booking_mapping ( %tmp = VALUE #( TravelID = booking-preliminary-travel_id
                                                                               BookingID = booking-preliminary-booking_id )
                                                                               TravelID = booking-final-travel_id
                                                                               BookingID = booking-final-booking_id ) ).


  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
