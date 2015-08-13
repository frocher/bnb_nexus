class Ability
  class << self
    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "Page" then page_abilities(user, subject)
      else []
      end.concat(global_abilities(user))
    end

    def global_abilities(user)
      rules = []
      rules
    end

    def page_abilities(user, page)
      rules = []

      members = page.page_members
      member = page.page_members.find_by_user_id(user.id)

      # Rules based on role in page
      if user.admin? || members.admins.include?(member)
        rules << page_admin_rules

      elsif members.masters.include?(member)
        rules << page_master_rules

      elsif members.guests.include?(member)
        rules << page_guest_rules

      end

      rules.flatten
    end


    def page_guest_rules
      [
        :read_page,
        :read_page_member
      ]
    end

    def page_master_rules
      page_guest_rules + [
        :create_page_member,
        :update_page_member,
        :delete_page_member
      ]
    end

    def page_admin_rules
      page_master_rules + [
        :create_page_member_admin,
        :delete_page,
        :update_page
      ]
    end
  end
end
