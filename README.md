# Unmanaged Travel

A transactional RESTful travel application based on SAP's unmanaged scenario.

This repository contains an ABAP-based implementation of a travel and booking domain model designed for use with SAP RAP (RESTful ABAP Programming Model) and OData services. It models the core business entities for managing travel bookings, associated customer and agency information, currency handling, flight details, and status values.

## Purpose

The project demonstrates the unmanaged scenario for travel processing in SAP ABAP, where business logic is implemented in a custom transactional application layer while exposing transactional CDS views and service definitions for consumption through APIs.

The main domain objects in the project are:

- Travel
- Booking
- Agency
- Customer
- Currency
- Flight / connection information
- Booking status

## Repository structure

```text
.
├── .abapgit.xml            # abapGit project metadata
├── LICENSE                 # MIT license
├── src/
│   ├── package.devc.xml   # ABAP package metadata
│   ├── zumngd_i_travel_u.ddls.asddls      # Travel interface view
│   ├── zumngd_c_travel_u.ddls.asddls      # Travel projection view
│   ├── zumngd_i_booking_u.ddls.asddls     # Booking interface view
│   ├── zumngd_c_booking_u.ddls.asddls     # Booking projection view
│   ├── zumngd_travel_u.srvd.srvdsrv       # OData service definition
│   ├── zunmgd_bp_travel_u.clas.abap       # Travel behavior class
│   ├── zumngd_bp_booking_u.clas.abap      # Booking behavior class
│   ├── zunmgd_cl_travel_auxiliary.clas.abap # Auxiliary logic for fail cause mapping
│   └── ...                                  # Generated ABAP metadata/XML artifacts
└── README.md
```

## Core ABAP objects

### CDS views

- `ZUMNGD_I_Travel_U`
  - Root interface entity for travel data
  - Includes associations to agency, customer, currency, and travel status
  - Composes bookings via the booking view

- `ZUMNGD_C_Travel_U`
  - Projection view for travel data
  - Exposes fields for agency name, customer name, memo, status text, and amount values
  - Declared with transactional query semantics

- `ZUMNGD_I_Booking_U`
  - Booking interface view based on `/DMO/booking`
  - Links each booking to its parent travel and associated customer/carrier/connection metadata

- `ZUMNGD_C_Booking_U`
  - Projection view for booking data
  - Exposes flight and pricing data and value help binding for airline, connection, flight date, and price

### Service definition

- `ZUMNGD_TRAVEL_U`
  - Exposes the data model as a service for UI and API consumption
  - Includes the following entities:
    - Travel
    - Booking
    - BookingSupplement
    - Supplement
    - SupplementCategory
    - Passenger
    - TravelAgency
    - Currency
    - Country
    - Airline
    - FlightConnection
    - Flight
    - Airport
    - TravelStatus

### Behavior classes

- `ZUNMGD_BP_TRAVEL_U`
- `ZUMNGD_BP_BOOKING_U`

These classes are defined for the behavior implementation of the travel and booking entities and form part of the transactional application layer.

### Auxiliary logic

- `ZUNMGD_CL_TRAVEL_AUXILIARY`

This helper class maps SAP message classes and message numbers to behavioral fail causes such as:

- not found
- dependency
- locked
- unauthorized
- unspecified

This is useful in RAP-managed transactional error handling for dependent operations.

## Business scenario

The application follows the SAP unmanaged travel scenario:

- A travel record has a header with dates, total price, agency, customer, and status.
- A travel can contain multiple related bookings.
- Each booking references airline, connection, flight date, and price.
- The data and behavior are exposed through CDS-based interfaces and an OData service layer.

This reflects a standard business process where travel and booking information is created, updated, and managed through a transactional backend service.

## Prerequisites

To work with this project, you need:

- An SAP ABAP system with support for CDS and RAP development
- Access to the standard SAP flight/travel base data model (`/DMO/*` objects)
- ABAP development tools or a suitable SAP development environment
- abapGit for importing the project into your SAP system

## Deployment

1. Clone the repository.
2. Import the project into your ABAP system using abapGit.
3. Ensure the package structure is created correctly in your SAP system.
4. Activate the generated ABAP objects in the target package.
5. Expose the service definition and test the travel booking API through your SAP gateway or OData service layer.

## Notes

- This repository is backend-centric and focuses on SAP ABAP data modeling and service exposure.
- It does not include a frontend application or UI project.
- The project is aligned with ABAP development practices for transactional business scenarios using CDS and behavior definitions.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
