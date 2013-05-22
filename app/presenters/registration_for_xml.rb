class RegistrationForXML

  extend Forwardable

  def_delegators  :@r, :full_name, :first_name, :middle_name, :last_name, :suffix,
                  :ssn, :created_at, :email, :phone, :dob, :gender,
                  :ca_type, :ca_address, :ca_address_2, :ca_city,
                  :vvr_street_number, :vvr_street_name, :vvr_street_type, :vvr_apt,
                  :vvr_town, :vvr_state, :vvr_state, :vvr_rural,
                  :ma_address, :ma_address_2, :ma_city, :ma_state, :mau_type, :mau_address, :mau_address_2, :mau_city, :mau_city_2,
                  :mau_state, :mau_postal_code, :mau_country,
                  :apo_address, :apo_address_2, :apo_city, :apo_state, :apo_zip5,
                  :pr_status,
                  :pr_street_number, :pr_street_name, :pr_street_type, :pr_apt,
                  :pr_city, :pr_state, :pr_zip5, :pr_zip4, :pr_is_rural, :pr_rural,
                  :rights_restored_in, :rights_restored_on,
                  :ab_reason,
                  :residential?

  def initialize(r)
    @r = r
  end

  def previous_registration_thoroughfare
    return nil unless pr_status == '1'

    [ @r.pr_street_number, @r.pr_street_name, @r.pr_street_type ].reject(&:blank?).join(' ')
  end

  def be_official?
    @r.be_official == '1'
  end

  def rights_revoked?
    @r.rights_revoked == '1'
  end

  def overseas?
    @r.uocava? && (/temporary/i =~ @r.outside_type.to_s)
  end

  def military?
    @r.uocava? && (/merchant/i =~ @r.outside_type.to_s)
  end

  def absentee_request?
    @r.requesting_absentee == '1'
  end

  def acp_request?
    @r.is_confidential_address == '1'
  end

  def need_assistance?
    @r.need_assistance == '1'
  end

  def felony?
    @r.rights_revoked_reason == 'felony'
  end

  def mental?
    @r.rights_revoked_reason == 'mental'
  end

  def ca_zip
    zip(@r.ca_zip5, @r.ca_zip4)
  end

  def ma_zip
    zip(@r.ma_zip5, @r.ma_zip4)
  end

  def vvr_is_rural?
    @r.vvr_is_rural == '1'
  end

  def vvr_thoroughfare
    [ @r.vvr_street_number, @r.vvr_street_name, @r.vvr_street_type ].rjoin(' ')
  end

  def pr_is_rural?
    @r.pr_is_rural == '1'
  end

  def pr_thoroughfare
    [ @r.pr_street_number, @r.pr_street_name, @r.pr_street_type ].rjoin(' ')
  end

  def vvr_zip
    zip(@r.vvr_zip5, @r.vvr_zip4)
  end

  def ma_is_different?
    @r.ma_is_different == '1'
  end

  def rights_restored?
    @r.rights_restored == '1'
  end

  def ab_type
    residential? ? Dictionaries::ABSENCE_REASON_TO_EML310[@r.ab_reason] : @r.outside_type
  end

  def ab_info
    if residential?
      election = @r.rab_election.blank? ? "#{@r.rab_election_name} on #{@r.rab_election_date}" : @r.rab_election
      address  = [
        [ @r.ab_street_number, @r.ab_street_name, @r.ab_street_type ].rjoin(' '),
        @r.ab_apt,
        [ @r.ab_city, @r.ab_state, zip(@r.ab_zip5, @r.ab_zip4) ].rjoin(' '),
        @r.ab_country ].rjoin(', ')
      time = [ @r.ab_time_1, @r.ab_time_2 ].join(' - ')

      [ election, address, @r.ab_field_1, @r.ab_field_2, time ].rjoin(' / ')
    else
      if @r.outside_type == "ActiveDutyMerchantMarineOrArmedForces" ||
         @r.outside_type == "SpouseOrDependentActiveDutyMerchantMarineOrArmedForces"

        [ @r.service_branch, @r.service_id, @r.rank ].rjoin(' ')
      end
    end
  end

  def residence_still_available?
    residential? || @r.vvr_uocava_residence_available == '1'
  end

  def date_of_last_residence
    @r.vvr_uocava_residence_unavailable_since.strftime("%Y-%m-%d")
  end

  private

  def zip(z5, z4)
    [ z5, z4 ].rjoin
  end

end
