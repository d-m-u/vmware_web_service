require 'VMwareWebService/PbmService'

module MiqPbmInventory
  def pbm_initialize(vim)
    begin
      # SPBM endpoint was introduced in vSphere Management SDK 5.5 and
      # isn't supported by Hosts (only vCenters)
      @pbm_svc = PbmService.new(vim) if apiVersion >= '5.5' && isVirtualCenter
    rescue => err
      $vim_log.warn("MiqPbmInventory: Failed to connect to SPBM endpoint: #{err}")
    end
  end

  def pbmProfilesByUid(_selspec = nil)
    profiles = {}
    return profiles if @pbm_svc.nil?

    begin
      profile_ids = @pbm_svc.queryProfile
      @pbm_svc.retrieveContent(profile_ids).to_a.each do |pbm_profile|
        uid = pbm_profile.profileId.uniqueId

        profiles[uid] = pbm_profile
      end
    rescue => err
      $vim_log.warn("MiqPbmInventory: pbmProfilesByUid: #{err}")
    end

    profiles
  end

  def pbmQueryAssociatedEntity(profile_ids)
    assoc_entities = {}
    return assoc_entities if @pbm_svc.nil?

    begin
      profile_ids.each do |profile_id|
        # If a string was passed in create a PbmProfileId object
        profile_id = RbVmomi::PBM::PbmProfileId(:uniqueId => profile_id) if profile_id.kind_of?(String)

        assoc_entities[profile_id.uniqueId] = @pbm_svc.queryAssociatedEntity(profile_id)
      end
    rescue => err
      $vim_log.warn("MiqPbmInventory: pbmQueryAssociatedEntity: #{err}")
    end

    assoc_entities
  end

  def pbmQueryMatchingHub(profile_ids)
    hubs = {}
    return hubs if @pbm_svc.nil?

    begin
      profile_ids.each do |profile_id|
        # If a string was passed in create a PbmProfileId object
        profile_id = RbVmomi::PBM::PbmProfileId(:uniqueId => profile_id) if profile_id.kind_of?(String)

        hubs[profile_id.uniqueId] = @pbm_svc.queryMatchingHub(profile_id)
      end
    rescue => err
      $vim_log.warn("MiqPbmInventory: pbmQueryMatchingHub: #{err}")
    end

    hubs
  end
end
