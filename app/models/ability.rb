class Ability
  class << self
    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "Site" then site_abilities(user, subject)
      else []
      end.concat(global_abilities(user))
    end

    def global_abilities(user)
      rules = []
      rules
    end

    def site_abilities(user, site)
      rules = []

      members = site.site_members
      member = site.site_members.find_by_user_id(user.id)

      # Rules based on role in site
      if user.admin? || members.admins.include?(member)
        rules << site_admin_rules

      elsif members.masters.include?(member)
        rules << site_master_rules

      elsif members.guests.include?(member)
        rules << site_guest_rules

      end

      rules.flatten
    end


    def site_guest_rules
      [
        :read_site,
        :read_site_member
      ]
    end

    def site_master_rules
      site_guest_rules + [
        :create_site_member,
        :update_site_member,
        :delete_site_member,
        :create_project_page,
        :update_project_page,
        :delete_project_page
      ]
    end

    def site_admin_rules
      site_master_rules + [
        :create_site_member_admin,
        :delete_site,
        :update_site
      ]
    end
  end
end
