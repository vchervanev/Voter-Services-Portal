module Dictionaries

  # All cities and counties in Virginia
  CITIES_AND_COUNTIES = [
    "ACCOMACK COUNTY",
    "ALBEMARLE COUNTY",
    "ALEXANDRIA CITY",
    "ALLEGHANY COUNTY",
    "AMELIA COUNTY",
    "AMHERST COUNTY",
    "APPOMATTOX COUNTY",
    "ARLINGTON COUNTY",
    "AUGUSTA COUNTY",
    "BATH COUNTY",
    "BEDFORD CITY",
    "BEDFORD COUNTY",
    "BLAND COUNTY",
    "BOTETOURT COUNTY",
    "BRISTOL CITY",
    "BRUNSWICK COUNTY",
    "BUCHANAN COUNTY",
    "BUCKINGHAM COUNTY",
    "BUENA VISTA CITY",
    "CAMPBELL COUNTY",
    "CAROLINE COUNTY",
    "CARROLL COUNTY",
    "CHARLES CITY COUNTY",
    "CHARLOTTE COUNTY",
    "CHARLOTTESVILLE CITY",
    "CHESAPEAKE CITY",
    "CHESTERFIELD COUNTY",
    "CLARKE COUNTY",
    "COLONIAL HEIGHTS CITY",
    "COVINGTON CITY",
    "CRAIG COUNTY",
    "CULPEPER COUNTY",
    "CUMBERLAND COUNTY",
    "DANVILLE CITY",
    "DICKENSON COUNTY",
    "DINWIDDIE COUNTY",
    "EMPORIA CITY",
    "ESSEX COUNTY",
    "FAIRFAX CITY",
    "FAIRFAX COUNTY",
    "FALLS CHURCH CITY",
    "FAUQUIER COUNTY",
    "FLOYD COUNTY",
    "FLUVANNA COUNTY",
    "FRANKLIN CITY",
    "FRANKLIN COUNTY",
    "FREDERICK COUNTY",
    "FREDERICKSBURG CITY",
    "GALAX CITY",
    "GILES COUNTY",
    "GLOUCESTER COUNTY",
    "GOOCHLAND COUNTY",
    "GRAYSON COUNTY",
    "GREENE COUNTY",
    "GREENSVILLE COUNTY",
    "HALIFAX COUNTY",
    "HAMPTON CITY",
    "HANOVER COUNTY",
    "HARRISONBURG CITY",
    "HENRICO COUNTY",
    "HENRY COUNTY",
    "HIGHLAND COUNTY",
    "HOPEWELL CITY",
    "ISLE OF WIGHT COUNTY",
    "JAMES CITY COUNTY",
    "KING & QUEEN COUNTY",
    "KING GEORGE COUNTY",
    "KING WILLIAM COUNTY",
    "LANCASTER COUNTY",
    "LEE COUNTY",
    "LEXINGTON CITY",
    "LOUDOUN COUNTY",
    "LOUISA COUNTY",
    "LUNENBURG COUNTY",
    "LYNCHBURG CITY",
    "MADISON COUNTY",
    "MANASSAS CITY",
    "MANASSAS PARK CITY",
    "MARTINSVILLE CITY",
    "MATHEWS COUNTY",
    "MECKLENBURG COUNTY",
    "MIDDLESEX COUNTY",
    "MONTGOMERY COUNTY",
    "NELSON COUNTY",
    "NEW KENT COUNTY",
    "NEWPORT NEWS CITY",
    "NORFOLK CITY",
    "NORTHAMPTON COUNTY",
    "NORTHUMBERLAND COUNTY",
    "NORTON CITY",
    "NOTTOWAY COUNTY",
    "ORANGE COUNTY",
    "PAGE COUNTY",
    "PATRICK COUNTY",
    "PETERSBURG CITY",
    "PITTSYLVANIA COUNTY",
    "POQUOSON CITY",
    "PORTSMOUTH CITY",
    "POWHATAN COUNTY",
    "PRINCE EDWARD COUNTY",
    "PRINCE GEORGE COUNTY",
    "PRINCE WILLIAM COUNTY",
    "PULASKI COUNTY",
    "RADFORD CITY",
    "RAPPAHANNOCK COUNTY",
    "RICHMOND CITY",
    "RICHMOND COUNTY",
    "ROANOKE CITY",
    "ROANOKE COUNTY",
    "ROCKBRIDGE COUNTY",
    "ROCKINGHAM COUNTY",
    "RUSSELL COUNTY",
    "SALEM CITY",
    "SCOTT COUNTY",
    "SHENANDOAH COUNTY",
    "SMYTH COUNTY",
    "SOUTHAMPTON COUNTY",
    "SPOTSYLVANIA COUNTY",
    "STAFFORD COUNTY",
    "STAUNTON CITY",
    "SUFFOLK CITY",
    "SURRY COUNTY",
    "SUSSEX COUNTY",
    "TAZEWELL COUNTY",
    "VIRGINIA BEACH CITY",
    "WARREN COUNTY",
    "WASHINGTON COUNTY",
    "WAYNESBORO CITY",
    "WESTMORELAND COUNTY",
    "WILLIAMSBURG CITY",
    "WINCHESTER CITY",
    "WISE COUNTY",
    "WYTHE COUNTY",
    "YORK COUNTY"
  ]

  STATES = [
    ['Alabama', 'AL'],
    ['Alaska', 'AK'],
    ['Arizona', 'AZ'],
    ['Arkansas', 'AR'],
    ['California', 'CA'],
    ['Colorado', 'CO'],
    ['Connecticut', 'CT'],
    ['Delaware', 'DE'],
    ['District of Columbia', 'DC'],
    ['Florida', 'FL'],
    ['Georgia', 'GA'],
    ['Hawaii', 'HI'],
    ['Idaho', 'ID'],
    ['Illinois', 'IL'],
    ['Indiana', 'IN'],
    ['Iowa', 'IA'],
    ['Kansas', 'KS'],
    ['Kentucky', 'KY'],
    ['Louisiana', 'LA'],
    ['Maine', 'ME'],
    ['Maryland', 'MD'],
    ['Massachusetts', 'MA'],
    ['Michigan', 'MI'],
    ['Minnesota', 'MN'],
    ['Mississippi', 'MS'],
    ['Missouri', 'MO'],
    ['Montana', 'MT'],
    ['Nebraska', 'NE'],
    ['Nevada', 'NV'],
    ['New Hampshire', 'NH'],
    ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'],
    ['New York', 'NY'],
    ['North Carolina', 'NC'],
    ['North Dakota', 'ND'],
    ['Ohio', 'OH'],
    ['Oklahoma', 'OK'],
    ['Oregon', 'OR'],
    ['Pennsylvania', 'PA'],
    ['Puerto Rico', 'PR'],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    ['Tennessee', 'TN'],
    ['Texas', 'TX'],
    ['Utah', 'UT'],
    ['Vermont', 'VT'],
    ['Virginia', 'VA'],
    ['Washington', 'WA'],
    ['West Virginia', 'WV'],
    ['Wisconsin', 'WI'],
    ['Wyoming', 'WY']
  ]

  STATES_WITHOUT_VA = STATES.reject { |n, k| k == 'VA' }

  STREET_TYPES = %w(
    ADN ALY ANX ARC ARCH AVE BCH BEND BLF BLVD BND BR BRG BRK BTM BYP CHS CIR CL CLF CLO CMN CMNS COR COVE
    CRES CRK CRS CRSE CRST CSWY CT CTR CURV CV DL DR EST ESTS EXPY EXT FALL FARM FLD FLDS FLT FR FRD FRST
    FWY GDNS GLN GRN GRV GTWY HBR HILL HL HLS HOLW HTS HVN HWY INLT IS ISLE JCT KNL KNLS KY LDG LINE LKS
    LN LNDG LOOP MALL MDWS MEWS ML MNR MT MTN NOOK OLK ORCH OVLK PARK PASS PATH PIKE PKWY PKY PL PLZ PNES
    PSGE PT PWY QTR QUAY RAMP RCH RD RDG RDS RET RIV RNG ROW RT RTE RUN SHR SMT SPG SPGS SPUR SQ ST STA TER
    TNG TPKE TRAK TRCE TRL TURN VIA VLG VLY VW WALK WAY WAYE XING YARD )

  NAME_SUFFIXES = [ "Jr", "Sr" ]

  ACP_REASONS = {
    'le'  => "Law Enforcement",
    'po'  => "Protective Order",
    'if'  => "Threatened / Stalked",
    'acp' => "Participage in Address Confidentiality Program"
  }

  PARTIES = [
    "American Independent Party",
    "Americans Elect Party",
    "Democratic Party",
    "Green Party",
    "Libertarian Party",
    "Peace and Freedom Party",
    "Republican Party"
  ]

  ABSENCE_REASONS = {
    '1A' => 'Student',
    '1B' => 'Spouse of student',
    '1C' => 'Business',
    '1D' => 'Personal business or vacation',
    '1E' => 'I am working and commuting to/from home for 11 or more hours between 6:00 AM and 7:00 PM on Election Day',
    '1F' => 'I am a first responder (member of law enforcement, fire fighter, emergency technician, search and rescue)',
    '2A' => 'My disability or illness',
    '2B' => 'I am primarily and personally responsible for the care of a disabled/ill family member confined at home',
    '2C' => 'My pregnancy',
    '3A' => 'Confined, awaiting trial',
    '3B' => 'Confined, convicted of a misdemeanor',
    '4A' => 'An electoral board member, registrar, officer of election, or custodian of voting equipment',
    '5A' => 'I have a religious obligation',
    '7A' => 'Requesting a ballot for presidential and vice-presidential electors only (Ballots for other offices/issues will not be sent)',
    '8A' => 'Designated representative of candidate or party inside polls'
  }

  ABSENCE_F1_LABEL = {
    '1A' => 'Name of school',
    '1B' => 'Name of school',
    '1C' => 'Name of employer or business',
    '1E' => 'Name of employer or business',
    '1D' => 'Place of travel (VA county/city or state or country)',
    '2A' => 'Nature of disability or illness',
    '2B' => 'Nature of disability or illness',
    '3A' => 'Place of confinement',
    '3B' => 'Place of confinement',
    '5A' => 'Religion',
    '8A' => 'Designated candidate party'
  }

  ABSENCE_F2_LABEL = {
    '2B' => 'Name of family member',
    '5A' => 'Nature of obligation'
  }

end
