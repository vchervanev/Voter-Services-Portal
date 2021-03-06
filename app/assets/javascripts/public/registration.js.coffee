formOption = (k) -> $("input##{k}").val()

class window.Registration
  constructor: (residence) ->
    @residence          = ko.observable(residence)
    @overseas           = ko.computed => @residence() == 'outside'
    @domestic           = ko.computed => !@overseas()
    
    @ssnRequired        = ko.observable($("input#ssn_required").val() == 'true')
    @requireAttestation        = ko.observable($("input#attestation_required").val() == 'true')
    @showDocImage       = ko.observable($("input#id_documentation_image_enabled").val() == 'true')
    @middleNameRequired = ko.computed =>
      gon.enable_names_virginia and !@noMiddleName()
    @nameSuffixRequired = ko.computed =>
      gon.enable_names_virginia and !@noSuffix()
    @allowInelligibleToCompleteForm = ko.observable($("input#allow_ineligible_to_complete_form").val() == 'true')
    @editMailingAddressAtProtectedVoter = ko.observable($("input#enable_edit_mailing_address_at_protected_voter").val() == 'true')
    @dmvIdCheckbox      = !!gon.require_transport_id_number
    @personalDataOnEligibilityPage = !!gon.personal_data_on_eligibility_page
    @virginiaAbsentee   = !!gon.virginia_absentee
    @useUSAddress       = !!gon.us_format
    @useCAAddress       = !!gon.canada_format
    @noCountyOrCity     = !gon.virginia_address
    @enableDMVAddressDisplay = !!gon.enable_dmv_address_display
    @enablePreviousRegistration = !!gon.enable_previous_registration
    @defaultState       = gon.default_state
    @paperlessPossible  = ko.observable()
    @lookupPerformed    = false

    @phonePatternDomestic = "({{999}}) {{999}}-{{9999}}"
    @phonePatternOverseas = "{{NNNNNNNNNNNNNNNNNNNN}}"
    $.fn.formatter.addInptType 'N', /[0-9 \-]/

    @initEligibilityFields()
    @initIdentityFields()

    @paperlessSubmission = ko.computed =>
      @paperlessPossible() and (@isConfidentialAddress() != '1' or @caType() != 'TSC')

    @showAssistantDetails = ko.computed =>
      el = $("input#enable_display_assistant_details")
      if @paperlessSubmission()
        el.attr('data-paperless') == 'true'
      else
        el.attr('data-paper') == 'true'

    @initAddressFields()
    @initOptionsFields()
    @initSummaryFields()
    @initOathFields()

  initEligibilityFields: ->
    @citizen                      = ko.observable()
    @eligibilityRequirements = []
    if gon.default_eligibility_config
      $('.eligibility_requirement input').each (i, el) =>
        observableName = $(el).data('observable')
        if observableName && observableName != '' && @eligibilityRequirements.indexOf(observableName) == -1
            @eligibilityRequirements.push(observableName)

    for req in @eligibilityRequirements
      @[req] = ko.observable()
      
    @oldEnough                    = ko.observable()
    @rightsFelony                 = ko.observable()
    @rightsMental                 = ko.observable()

    @expandedRights               = !!gon.enable_expanded_felony_mental_eligibility
    if @expandedRights
      @rightsWereRevoked          = ko.computed => if (@rightsFelony() == '1' or @rightsMental() == '1') then '1' else '0'
      @expandRightsQuestions      = ko.observable(true)
    else
      @rightsWereRevoked          = ko.observable()
      @expandRightsQuestions      = ko.computed => @rightsWereRevoked() == '1'

    @dobYear                      = ko.observable()
    @dobMonth                     = ko.observable()
    @dobDay                       = ko.observable()
    @dob                          = ko.computed => pastDate(@dobYear(), @dobMonth(), @dobDay())
    @ssn                          = ko.observable()
    @noSSN                        = ko.observable()
    @hasSSN                       = ko.computed => filled(@ssn())
    @dmvId                        = ko.observable()
    @noDmvId                      = ko.observable()
    @docImageType                 = ko.observable()
    @docImage                     = ko.observable()
    @noDocImage                   = ko.observable()
    @noDocImageSelected           = ko.computed => @docImageType() == ''
    


    @rightsFelonyRestored         = ko.observable()
    @rightsMentalRestored         = ko.observable()
    @rightsFelonyRestoredOnMonth  = ko.observable()
    @rightsFelonyRestoredOnYear   = ko.observable()
    @rightsFelonyRestoredOnDay    = ko.observable()
    @rightsMentalRestoredOnMonth  = ko.observable()
    @rightsMentalRestoredOnYear   = ko.observable()
    @rightsMentalRestoredOnDay    = ko.observable()
    @rightsFelonyRestoredIn       = ko.observable()
    @rightsFelonyRestoredInText   = ko.computed => $("#registration_rights_felony_restored_in option[value='#{@rightsFelonyRestoredIn()}']").text()
    @rightsFelonyRestoredOn       = ko.computed => dateInRange(@rightsFelonyRestoredOnYear(), @rightsFelonyRestoredOnMonth(), @rightsFelonyRestoredOnDay(), @dob(), new Date())
    @rightsMentalRestoredOn       = ko.computed => dateInRange(@rightsMentalRestoredOnYear(), @rightsMentalRestoredOnMonth(), @rightsMentalRestoredOnDay(), @dob(), new Date())

    # if personal data is on identity page, we need to revalidate (for red highlighting)
    # rights restoration dates on the eligibility page
    if !@personalDataOnEligibilityPage
      @dob.subscribe (v) =>
        return if !v
        $(".rights_revoked select").trigger("validate")

    @noSSN.subscribe (v) =>
      if v
        @ssn(null)
        setTimeout (-> $("#registration_ssn").removeAttr('data-visited')), 1
      else
        setTimeout (-> $("#registration_ssn").focus()), 1

    @noDmvId.subscribe (v) =>
      if v
        @dmvId(null)
        setTimeout (-> $("#registration_dmv_id").removeAttr('data-visited')), 1
      else
        setTimeout (-> $("#registration_dmv_id").focus()), 1

    @noDocImage.subscribe (v) =>
      if v
        @docImage(null)
        @docImageType(null)
        setTimeout (-> $("#registration_id_documentation_image").removeAttr('data-visited')), 1
      else
        setTimeout (-> $("#registration_id_documentation_image").focus()), 1

    @docImageName = ko.computed =>
      if @docImage()
        @docImage().split( '\\' ).pop();
      else
        null
      
    @docImage.subscribe (v) =>
      if v
        fileName = @docImageName();
        if fileName
          $("label.file-upload-button.id_documentation_image").text(fileName);
        

    @hasEligibleRights = ko.computed =>
      (@rightsWereRevoked() == '0' or
        ((@rightsFelony() == '1' or @rightsMental() == '1') and
         (@rightsFelony() == '0' or (@rightsFelonyRestored() == '1' and filled(@rightsFelonyRestoredIn()) and !!@rightsFelonyRestoredOn())) and
         (@rightsMental() == '0' or (@rightsMentalRestored() == '1' and !!@rightsMentalRestoredOn()))))

    

    @rightsNotFilled = ko.computed =>
      rightsOptionsNotFilled =
        (!filled(@rightsFelony()) or !filled(@rightsMental())) or
        (!@expandedRights and @rightsFelony() != '1' and @rightsMental() != '1') or
        (@rightsFelony() == '1' and !filled(@rightsFelonyRestored())) or
        (@rightsMental() == '1' and !filled(@rightsMentalRestored()))

      if @expandedRights then rightsOptionsNotFilled else (!filled(@rightsWereRevoked()) or (@rightsWereRevoked() == '1' and rightsOptionsNotFilled))

    @invalidRightsRestorationDate = ko.computed =>
      return false if !@expandedRights and @rightsWereRevoked() != '1'
      (@rightsFelony() == '1' and @rightsFelonyRestored() == '1' and !@rightsFelonyRestoredOn()) or
      (@rightsMental() == '1' and @rightsMentalRestored() == '1' and !@rightsMentalRestoredOn())

    @eligibilityErrors = ko.computed =>
      errors = []
      @validateEligibilityData(errors)
      @validatePersonalData(errors) if @personalDataOnEligibilityPage
      errors
      
    @isEligible = ko.computed =>
      if gon.default_eligibility_config
        @eligibilityErrors().length == 0
      else
        (@citizen() == '1' and
        @oldEnough() == '1' and
        !!@dob() and
        (!@ssnRequired() or (!@noSSN() and filled(@ssn()))) and
        @hasEligibleRights())
        
    @eligibilityInvalid = ko.computed => @eligibilityErrors().length > 0

  updatePhoneField: ->
    phoneEl = $("#registration_phone")

    if @overseas()
      phoneEl.formatter().resetPattern @phonePatternOverseas
      phoneEl.attr('placeholder', '')
    else
      phoneEl.formatter().resetPattern @phonePatternDomestic
      phoneEl.attr('placeholder', '(NNN) NNN-NNNN')

  initIdentityFields: ->
    @namePrefix                 = ko.observable()
    @firstName              = ko.observable()
    @middleName             = ko.observable()
    @lastName               = ko.observable()
    @nameSuffix             = ko.observable()
    @gender                 = ko.observable()
    @phone                  = ko.observable()
    @fax                    = ko.observable()
    @validPhone             = ko.computed => !filled(@phone()) or phone(@phone())
    @validFax               = ko.computed => !filled(@fax()) or phone(@fax())
    @email                  = ko.observable()
    @validEmail             = ko.computed => !filled(@email()) or email(@email())
    @caType                 = ko.observable()
    @isConfidentialAddress  = ko.observable()
    
    if phoneEl = $("#registration_phone")
      phoneEl.formatter({ pattern: @phonePatternDomestic })
      @overseas.subscribe => @updatePhoneField()
      @updatePhoneField()

    if gon.enable_names_virginia
      @noMiddleName           = ko.observable()
      @middleNameEnabled      = ko.computed => !@noMiddleName()
      @noSuffix               = ko.observable()
      @suffixEnabled          = ko.computed => !@noSuffix()
    
      @noMiddleName.subscribe (v) =>
        if v
          @middleName(null)
          $("#registration_middle_name").removeAttr('data-visited')
        else
          $("input#registration_middle_name[type='text']").focus()

      @noSuffix.subscribe (v) =>
        if v
          @suffix('')
        else
          $("select#registration_suffix").focus()

    @isConfidentialAddress.subscribe (v) =>
      @caType(null) unless v

    @needsProtectedMailingAddress = ko.computed =>
      @isConfidentialAddress() and @domestic() and (@editMailingAddressAtProtectedVoter() or !@maIsDifferent())

    @protectedVoterAdditionals = ko.computed =>
      (@isConfidentialAddress() and @caType() == 'TSC') or @needsProtectedMailingAddress()

    @identityErrors = ko.computed =>
      errors = []
      if gon.eligibility_with_identity 
        @validateEligibilityData(errors)        
      
      errors.push('Given name') unless filled(@firstName())
      errors.push('Surname (last name)') unless filled(@lastName())
      errors.push('Gender') unless filled(@gender())
      errors.push('Phone number') unless @validPhone()
      errors.push('Email address') unless @validEmail()
      if !@personalDataOnEligibilityPage && @invalidRightsRestorationDate()
        errors.push('The date of restoration of voting rights must be after your date of birth. Please correct your date of birth or go back to to correct your restoration date.')


      if (@middleNameRequired() and !filled(@middleName()))
        errors.push('Middle name')

      if (@nameSuffixRequired() and !filled(@nameSuffix()))
        errors.push('Name suffix')

      if @isConfidentialAddress()
        if !filled(@caType())
          errors.push("Address confidentiality reason")
        else
          if @domestic() and !@domesticMAFilled()
            errors.push("Protected voter mailing address")

      @validatePersonalData(errors) if !@personalDataOnEligibilityPage

      errors

    @identityInvalid = ko.computed => @identityErrors().length > 0

  default_eligibility_config_errors: ->
    errors = []
    inputs = $(".eligibility_requirement input[type=checkbox], .eligibility_requirement input[type=radio]")
    for req in @eligibilityRequirements
      observableValue = @[req]()
      input = $("input[data-observable=#{req}]")
      error = $(input).parents(".eligibility_requirement").find(".ineligible_message").text().trim()
      if !(observableValue == true || observableValue == "1")
        errors.push(error)

    errors

  validateEligibilityData: (errors) ->
    if gon.default_eligibility_config
      for error in @default_eligibility_config_errors()
        errors.push(error)
    else
      errors.push("Citizenship criteria") unless @citizen()
      errors.push("Age criteria") unless @oldEnough()
      errors.push("Voting rights criteria") if @rightsNotFilled()
      errors.push("The date of restoration must be after your date of birth.") if @invalidRightsRestorationDate()
    errors.push(gon.i18n_id_documentation_image) if @showDocImage() and !@noDocImage() and (!@docImageType() or !@docImage())
    
    
  validatePersonalData: (errors) ->
    errors.push('Date of birth') unless @dob()
    errors.push('Social Security #') if !ssn(@ssn()) and !@noSSN() and @ssnRequired()
    errors.push(gon.i18n_dmvid) if @dmvIdCheckbox and !isDmvId(@dmvId()) and !@noDmvId()
    
  initAddressFields: ->
    @maIsDifferent          = ko.observable(false)
    @prStatus               = ko.observable()
    @prIsRural              = ko.observable(false)
    
    if @useUSAddress
      @vvrIsRural             = ko.observable()
      @vvrAddress1            = ko.observable()
      @vvrAddress2            = ko.observable()

    if @useCAAddress
      @caAddressType        = ko.observable("1")
      @caAddressStreetNumber = ko.observable()
      @caAddressStreetName = ko.observable()
      @caAddressStreetType = ko.observable()
      @caAddressDirection = ko.observable()
      @caAddressUnit = ko.observable()
    
    @vvrApt                 = ko.observable()
    @vvrTown                = ko.observable()
    @vvrState               = ko.observable(@defaultState)
    @vvrZip5                = ko.observable()
    @vvrZip4                = ko.observable()
    @vvrCountyOrCity        = ko.observable()
    @vvrOverseasRA          = ko.observable()
    @vvrUocavaResidenceUnavailableSinceDay = ko.observable()
    @vvrUocavaResidenceUnavailableSinceMonth = ko.observable()
    @vvrUocavaResidenceUnavailableSinceYear = ko.observable()
    @vvrUocavaResidenceUnavailableSince = ko.computed => pastDate(@vvrUocavaResidenceUnavailableSinceYear(), @vvrUocavaResidenceUnavailableSinceMonth(), @vvrUocavaResidenceUnavailableSinceDay())
    
    @maAddress1             = ko.observable()
    @maAddress2             = ko.observable()
    @maCity                 = ko.observable()
    @maState                = ko.observable()
    @maZip5                 = ko.observable()
    @maZip4                 = ko.observable()
    @mauType                = ko.observable('non-us')
    @mauAPOAddress1         = ko.observable()
    @mauAPOAddress2         = ko.observable()
    @mauAPO1                = ko.observable()
    @mauAPO2                = ko.observable()
    @mauAPOZip5             = ko.observable()
    @mauAddress             = ko.observable()
    @mauAddress2            = ko.observable()
    @mauCity                = ko.observable()
    @mauState               = ko.observable()
    @mauPostalCode          = ko.observable()
    @mauCountry             = ko.observable()
    @prFirstName            = ko.observable()
    @prMiddleName           = ko.observable()
    @prLastName             = ko.observable()
    @prSuffix               = ko.observable()
    @prAddress1             = ko.observable()
    @prAddress2             = ko.observable()
    @prCity                 = ko.observable()
    @prState                = ko.observable()
    @prZip5                 = ko.observable()
    @prZip4                 = ko.observable()
    @prCountyOrCity         = ko.observable()
    @prCancel               = ko.observable()

    @domesticMAFilled = ko.computed =>
      filled(@maAddress1()) and
      filled(@maCity()) and
      filled(@maState()) and
      zip5(@maZip5())

    @nonUSMAFilled = ko.computed =>
      filled(@mauAddress()) and
      filled(@mauCity()) and
      filled(@mauState()) and
      filled(@mauPostalCode()) and
      filled(@mauCountry())

    @overseasMAFilled = ko.computed =>
      if   @mauType() == 'apo'
      then filled(@mauAPOAddress1()) and filled(@mauAPO1()) and zip5(@mauAPOZip5())
      else @nonUSMAFilled()

    @addressesErrors = ko.computed =>
      errors = []

      residential =
        ((@useUSAddress and filled(@vvrAddress1())) or (@useCAAddress and
         filled(@caAddressStreetNumber()) and 
         filled(@caAddressStreetName()) and 
         filled(@caAddressStreetType()))) and
         filled(@vvrTown()) and
         filled(@vvrState()) and
         ((@useUSAddress and zip5(@vvrZip5())) or (@useCAAddress and caPostalCode(@vvrZip5()))) and
         (filled(@vvrCountyOrCity()) || @noCountyOrCity)

      if @overseas()
        residential = residential and
          filled(@vvrOverseasRA()) and
          (@vvrOverseasRA() == '1' or @vvrUocavaResidenceUnavailableSince())
        mailing = @overseasMAFilled()
      else
        mailing = !@maIsDifferent() or @domesticMAFilled()

      previous = !@enablePreviousRegistration or (
        filled(@prStatus()) and (
          @prStatus() != '1' or
          filled(@prFirstName()) and
          filled(@prLastName()) and
          @prCancel() and
          filled(@prAddress1()) and
          filled(@prState()) and
          filled(@prCity()) and
          zip5(@prZip5())
        ))

      errors.push("Registration address") unless residential
      errors.push("Mailing address") unless mailing
      errors.push("Previous registration") unless previous
      errors

    @addressesInvalid = ko.computed => @addressesErrors().length > 0

  saveOriginalRegAddress: =>
    if @useUSAddress
      @initialVvrAddress = {
        address_1:      @vvrAddress1(),
        address_2:      @vvrAddress2(),
        county_or_city: @vvrCountyOrCity(),
        town:           @vvrTown(),
        zip5:           @vvrZip5(),
        zip4:           @vvrZip4()
      }
    if @useCAAddress
      @initialVvrAddress = {
        address_1:      [@caAddressStreetNumber(), @caAddressStreetName(), @caAddressStreetType()].join(' '),
        address_2:      [@caAddressDirection(), @caAddressUnit()].join(' '),
        county_or_city: @vvrCountyOrCity(),
        town:           @vvrTown(),
        zip5:           @vvrZip5(),
        zip4:           @vvrZip4()
      }

  initOptionsFields: ->
    @party                  = ko.observable()
    @chooseParty            = ko.observable()
    @otherParty             = ko.observable()

    @needsAssistance        = ko.observable()

    @requestingAbsentee     = ko.observable()
    @rabType                = ko.observable()
    @absenteeUntil          = ko.observable()
    @rabElection            = ko.observable()
    @rabElectionName        = ko.observable()
    @rabElectionDate        = ko.observable()
    @outsideType            = ko.observable()
    @needsServiceDetails    = ko.computed => @outsideType() && @outsideType().match(/MerchantMarine/)
    @serviceBranch          = ko.observable()
    @serviceId              = ko.observable()
    @rank                   = ko.observable()

    @residence.subscribe (v) =>
      @requestingAbsentee(v == 'outside')

    @abReason               = ko.observable()
    @abField1               = ko.observable()
    @abField2               = ko.observable()
    @abStreetNumber         = ko.observable()
    @abStreetName           = ko.observable()
    @abStreetType           = ko.observable()
    @abApt                  = ko.observable()
    @abCity                 = ko.observable()
    @abState                = ko.observable()
    @abZip5                 = ko.observable()
    @abZip4                 = ko.observable()
    @abCountry              = ko.observable()
    @abTime1Hour            = ko.observable()
    @abTime1Minute          = ko.observable()
    @abTime2Hour            = ko.observable()
    @abTime2Minute          = ko.observable()

    @abAddressRequired = ko.computed =>
      r = @abReason()
      r == '1A' or
      r == '1B' or
      r == '1E' or
      r == '3A' or r == '3B'

    @abField1Required = ko.computed =>
      r = @abReason()
      r == '1A' or
      r == '1B' or
      r == '1C' or
      r == '1D' or
      r == '1E' or
      r == '2A' or
      r == '2B' or
      r == '3A' or r == '3B' or
      r == '5A' or
      r == '8A'

    @abField2Required = ko.computed =>
      r = @abReason()
      r == '2B' or
      r == '5A'

    @abTimeRangeRequired = ko.computed =>
      @abReason() == '1E'

    @abPartyLookupRequired = ko.computed =>
      @abReason() == '8A'

    @abField1Label = ko.computed =>
      r = @abReason()
      if r == '1A' or r == '1B'
        "Name of school"
      else if r == '1C' or r == '1E'
        "Name of employer or businesss"
      else if r == '1D'
        "Place of travel<br/>VA county/city, state or country"
      else if r == '2A' or r == '2B'
        "Nature of disability or illness"
      else if r == '3A' or r == '3B'
        "Place of confinement"
      else if r == '5A'
        "Religion"
      else if r == '8A'
        "Designated candidate party"

    @abField2Label = ko.computed =>
      r = @abReason()
      if r == '2B'
        "Name of family member"
      else if r == '5A'
        "Nature of obligation"

    @absenteeUntilFormatted = ko.computed =>
      au = @absenteeUntil()
      if !au or au.match(/^\s*$/)
        ""
      else
        moment(au).format("MMM D, YYYY")

    @beOfficial = ko.observable()

    @overseas.subscribe (v) =>
      setTimeout((=> @requestingAbsentee(true)), 0) if v

    @optionsErrors = ko.computed =>
      errors = []
      if @chooseParty()
        if !filled(@party()) || (@party() == 'other' and !filled(@otherParty()))
          errors.push("Party preference")

      if @requestingAbsentee() && @virginiaAbsentee
        if @overseas() and !filled(@rabType())
          errors.push("Request period")
        else if @overseas() and @rabType() == 'until'
          errors.push("Absence type") unless filled(@outsideType())
          errors.push("Service details") if @needsServiceDetails() and (!filled(@serviceId()) || !filled(@rank()))
        else
          if !filled(@rabElection()) or (@rabElection() == 'other' and (!filled(@rabElectionName()) or !filled(@rabElectionDate())))
            errors.push("Election details")

          if !filled(@abReason())
            errors.push("Absence reason")

          if @abAddressRequired() and
            (!filled(@abStreetNumber()) or
            !filled(@abStreetName()) or
            !filled(@abCity()) or
            !filled(@abState()) or
            !zip5(@abZip5()) or
            !filled(@abCountry()))
              errors.push("Address in supporting information")

          if @abTimeRangeRequired() and
            (!filled(@abTime1Hour()) or
            !filled(@abTime1Minute()) or
            !filled(@abTime2Hour()) or
            !filled(@abTime2Minute()))
              errors.push("Time range in supporting information")

          if @abField1Required() and
            !filled(@abField1())
              errors.push(@abField1Label())

          if @abField2Required() and
            !filled(@abField2())
              errors.push(@abField2Label())

      errors

    @optionsInvalid = ko.computed => @optionsErrors().length > 0

  setAbsenteeUntil: (val) ->
    @absenteeUntil(val)
    $("#registration_absentee_until").val(val)

  initAbsenteeUntilSlider: ->
    return if @abstenteeUntilSlider
    rau = $("#registration_absentee_until").val()
    @setAbsenteeUntil(rau)

    days = Math.floor((moment(rau) - moment()) / 86400000)
    @absenteeUntilSlider = $("#absentee_until")
    @absenteeUntilSlider.slider(min: 45, max: 365, value: days, slide: @onAbsenteeUntilSlide)

  onAbsenteeUntilSlide: (e, ui) =>
    val = moment().add('days', ui.value).format("YYYY-MM-DD")
    @setAbsenteeUntil(val)
    true

  initSummaryFields: ->
    @summaryFullName = ko.computed =>
      valueOrUnspecified(join([ @firstName(), @middleName(), @lastName(), @nameSuffix() ], ' '))

    @summaryEligibility = ko.computed =>
      items = []
      if gon.default_eligibility_config
        if @default_eligibility_config_errors().length == 0
          items.push "Agree to eligibility"
        else
          items.push "Does not agree to eligibility"
      else
        if @citizen()
          items.push "U.S. citizen"
        else
          items.push "Not a U.S. citizen"

        if @domestic()
          items.push "VA resident"

        if @oldEnough()
          items.push "Over 18 by next election"
        else
          items.push "Not over 18 by next election"

      items.join(', ')

    @summaryGender    = ko.computed => valueOrUnspecified(@gender())

    @summaryVotingRights = ko.computed =>
      if !filled(@rightsWereRevoked())
        "Unspecified"
      else if @rightsWereRevoked() == '0'
        "Not revoked"
      else
        lines = [ "Restored:" ]

        if @rightsFelony() == '1'
          line = "Convicted in #{@rightsFelonyRestoredIn()}"
          if @rightsFelonyRestored() == '1' and @rightsFelonyRestoredOn()
            line = "#{line}, restored on #{moment(@rightsFelonyRestoredOn()).format('MMMM D, YYYY')}"
          lines.push line

        if @rightsMental() == '1'
          line = "Judged mentally incapacitated"
          if @rightsMentalRestored() == '1' and @rightsMentalRestoredOn()
            line = "#{line}, and restored on #{moment(@rightsMentalRestoredOn()).format('MMMM D, YYYY')}"
          lines.push line

        lines.join "<br/>"

    @summarySSN = ko.computed =>
      if @noSSN() || !filled(@ssn()) then "none" else @ssn()
    @summaryDMVID = ko.computed =>
      if @noDmvId() || !filled(@dmvId()) then "none" else @dmvId()
    @summaryIdDocument = ko.computed =>
      if @noDocImage() || !filled(@docImage()) then "none" else @docImageName()
    @summaryDOB = ko.computed =>
      if filled(@dobMonth()) && filled(@dobDay()) && filled(@dobYear())
        moment([ @dobYear(), parseInt(@dobMonth()) - 1, @dobDay() ]).format("MMMM D, YYYY")
      else
        "Unspecified"

    @summaryRegistrationAddress = ko.computed =>
      address = null
      if @useUSAddress
        address =
          join([ @vvrAddress1(), @vvrAddress2() ], ' ') + "<br/>" +
          join([ @vvrTown(), join([ @vvrState(), join([ @vvrZip5(), @vvrZip4() ], '-') ], ' ') ], ', ')
        if !@noCountyOrCity
          address += "<br/>" + @vvrCountyOrCity()
      if @useCAAddress
        address =
          join([ @caAddressStreetNumber(), @caAddressStreetName(), @caAddressStreetType(), @caAddressDirection(), @caAddressUnit() ], ' ') + "<br/>" +
          join([ @vvrTown(), join([ @vvrState(), join([ @vvrZip5(), @vvrZip4() ], '-') ], ' ') ], ', ')
        
        
      if @overseas()
        lines = [ address ]
        if @vvrOverseasRA() == '0'
          lines.push "Last day available: #{moment(@vvrUocavaResidenceUnavailableSince()).format("MMMM Do, YYYY")}"
        lines.join "<br/>"
      else
        address

    @summaryOverseasMailingAddress = ko.computed =>
      if @mauType() == 'apo'
        join([
          @mauAPOAddress1(),
          @mauAPOAddress2(),
          join([ @mauAPO1(), @mauAPO2(), @mauAPOZip5() ], ', ')
        ], "<br/>")
      else
        join([
          @mauAddress(),
          @mauAddress2(),
          join([ @mauCity(), join([ @mauState(), @mauPostalCode()], ' '), @mauCountry()], ', ')
        ], "<br/>")


    @summaryExistingRegistration = ko.computed =>
      if @prStatus() != '1'
        gon.i18n_confirm_prev_reg_not_reg
      else
        lines = []

        lines.push valueOrUnspecified(join([ @prFirstName(), @prMiddleName(), @prLastName(), @prSuffix() ], ' '))

        lines.push join([ @prAddress1(), @prAddress2() ], ' ')
        lines.push join([ @prCity(), join([ @prState(), join([ @prZip5(), @prZip4() ], '-') ], ' ') ], ', ')
        lines.push @prCountyOrCity() if filled(@prCountyOrCity())
        lines.push "Authorized cancelation" if @prCancel()

        lines.join "<br/>"

    @summaryDomesticMailingAddress = ko.computed =>
      join([
        @maAddress1(),
        @maAddress2(),
        join([ @maCity(), join([ @maState(), join([ @maZip5(), @maZip4()], '-')], ' ')], ', ')
      ], "<br/>")

    @summaryMailingAddress = ko.computed =>
      if @overseas()
        @summaryOverseasMailingAddress()
      else
        if @maIsDifferent() or @isConfidentialAddress()
          @summaryDomesticMailingAddress()
        else
          @summaryRegistrationAddress()

    @summaryPhone = ko.computed =>
      if filled(@phone()) then @phone() else gon.i18n_confirm_not_provided
    @summaryFax = ko.computed =>
      if filled(@fax()) then @fax() else gon.i18n_confirm_not_provided
    @summaryEmail = ko.computed =>
      if filled(@email()) then @email() else gon.i18n_confirm_not_provided

    @summaryNeedsAssistance = ko.computed =>
      if @needsAssistance() then gon.i18n_confirm_required else gon.i18n_confirm_not_required

    @summaryBeOfficial = ko.computed =>
      if @beOfficial() then gon.i18n_confirm_required else gon.i18n_confirm_not_required

    @summaryAbsenteeRequest = ko.computed =>
      lines = []

      if @overseas()
        lines = []
        type = $("label", $(".overseas_outside_type input[value='#{@outsideType()}']").parent()).text()
        if @rabType() == 'until'
          lines.push "Reason: #{type}"

          if @needsServiceDetails()
            branch = $("#registration_service_branch option[value='#{@serviceBranch()}']").text()
            lines.push "Service details: #{branch} - #{@serviceId()} - #{@rank()}"
        else
          @errorsForRabElection lines

      else
        # domestic
        @errorsForRabElection lines

      lines.join "<br/>"

    @showingPartySummary = ko.computed =>
      @requestingAbsentee() and @overseas() and @rabType() == 'until' and @summaryParty()

    @summaryParty = ko.computed =>
      if @chooseParty()
        if @party() == 'other'
          @otherParty()
        else
          @party()
      else
        null

    @summaryElection = ko.computed =>
      if @rabElection() == 'other'
        "#{@rabElectionName()} on #{@rabElectionDate()}"
      else
        v = @rabElection()
        $("#registration_rab_election option[value='#{v}']").text()

  errorsForRabElection: (lines) ->
    if @rabElection() != 'other'
      election = @rabElection()
    else
      election = "#{@rabElectionName()} held on #{@rabElectionDate()}"
    lines.push "Applying to vote abstentee in #{election}"

    if filled(@abReason())
      lines.push "Reason: #{$("#registration_ab_reason option[value='#{@abReason()}']").text()}"

    if @abField1Required() and filled(@abField1())
      v = @abField1()
      if @abPartyLookupRequired()
        v = $("#registration_ab_field_1 option[value='#{v}']").text()
      lines.push "#{@abField1Label()}: #{v}"
    if @abField2Required() and filled(@abField2())
      lines.push "#{@abField2Label()}: #{@abField2()}"
    if @abTimeRangeRequired()
      h1 = @abTime1Hour()
      m1 = @abTime1Minute()
      h2 = @abTime2Hour()
      m2 = @abTime2Minute()
      lines.push "Time: #{time(h1, m1)} - #{time(h2, m2)}"
    if @abAddressRequired()
      lines.push join([ @abStreetNumber(), @abStreetName(), @abStreetType(), (if filled(@abApt()) then "##{@abApt()}" else null) ], ' ') + "<br/>" +
        join([ @abCity(), join([ @abState(), join([ @abZip5(), @abZip4() ], '-'), @abCountry() ], ' ') ], ', ')

  initOathFields: ->
    @infoCorrect  = ko.observable()
    @asFirstName  = ko.observable()
    @asMiddleName = ko.observable()
    @asLastName   = ko.observable()
    @asSuffix     = ko.observable()
    @asAddress1   = ko.observable()
    @asAddress2   = ko.observable()
    @asCity       = ko.observable()
    @asState      = ko.observable()
    @asZip5       = ko.observable()
    @asZip4       = ko.observable()

    @oathErrors = ko.computed =>
      errors = []
      errors.push("Confirm that information is correct") unless !@requireAttestation() or @infoCorrect()

      unless @paperlessSubmission()
        fn = filled(@asFirstName())
        ln = filled(@asLastName())
        a  = filled(@asAddress1())
        c  = filled(@asCity())
        s  = filled(@asState())

        reqAInfo = fn || ln || a || c || s ||
                   filled(@asMiddleName()) ||
                   filled(@asSuffix()) ||
                   filled(@asAddress2()) ||
                   filled(@asZip5()) ||
                   filled(@asZip4())

        if reqAInfo && (!fn || !ln)
          errors.push("Assistant name")

        if reqAInfo && (!a || !c || !s || !zip5(@asZip5()))
          errors.push("Assistant address")

      errors

    @oathInvalid = ko.computed => @oathErrors().length > 0

  checkEligibility: (_, e) =>
    return if $(e.target).hasClass('disabled')
    if @isEligible() or @allowInelligibleToCompleteForm()
      if @personalDataOnEligibilityPage
        @gotoPage('identity')
      else
        @performLookup(_, e)
    else
      @gotoPage('ineligible')

  performLookup: (_, e) =>
    if @lookupPerformed
      @gotoPage('address')
    else
      @lookupPerformed = true
      @lookupRecord(_, e)

  onLookupResult: (data) =>
    @paperlessPossible(!!gon.enable_digital_ovr and data.dmv_match )
    if @enableDMVAddressDisplay
      a = data.address || @initialVvrAddress
      if @useUSAddress
        @vvrAddress1(a.address_1)
        @vvrAddress2(a.address_2)
      if @useCAAddress
        @caAddressStreetName(a.address_1)
      if !@noCountyOrCity
        @vvrCountyOrCity(a.county_or_city || '')
      @vvrTown(a.town)
      @vvrZip5(a.zip5)
      @vvrZip4(a.zip4 || '')
    @page('address')
    #location.hash = 'address'

  lookupRecord: (_, e) =>
    return if $(e.target).hasClass('disabled')
    @page('lookup_record')

    if !gon.enable_dmvid_lookup or !filled(@dmvId()) or !filled(@ssn()) or (@isConfidentialAddress() and @caType() == 'TSC')
      return @onLookupResult({
        registered: false,
        dmv_match: !gon.enable_dmvid_lookup,
        address: @initialVvrAddress })

    $.getJSON '/lookup/registration', { record: {
        eligible_citizen:               if @citizen() then 'T' else 'F',
        eligible_18_next_election:      if @oldEnough() then 'T' else 'F',
        eligible_va_resident:           if @residence() == 'in' then 'T' else 'F',
        eligible_unrevoked_or_restored: if @hasEligibleRights() then 'T' else 'F',
        dob_month:                      @dobMonth(),
        dob_day:                        @dobDay(),
        dob_year:                       @dobYear(),
        ssn:                            @ssn(),
        dmv_id:                         @dmvId()
      }}, @onLookupResult

  nextFromEligibility: (_, e) =>
    if @personalDataOnEligibilityPage
      @checkEligibility(_, e)
    else
      @gotoPage('identity', e)

  nextFromIdentity: (_, e) =>
    if !@personalDataOnEligibilityPage
      @checkEligibility(_, e)
    else
      @performLookup(_, e)

  backFromIdentity: (_, e) =>
    @gotoPage('eligibility', e)

  backFromIneligible: (_, e) =>
    if @personalDataOnEligibilityPage
      @gotoPage('eligibility', e)
    else
      @gotoPage('identity', e)
