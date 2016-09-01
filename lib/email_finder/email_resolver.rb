require 'google-search'
require 'email_finder/email_pattern_resolver'
require 'email_finder/utils'

module EmailFinder
  class EmailResolver
    include Utils
    attr_reader :domain

    SAMPLE_FIRST_NAME     = 'SAMPLE'
    SAMPLE_LAST_NAME      = 'EMPLOYEE'
    SAMPLE_DOMAIN         = 'sample.com'

    BLACKLISTED_EMAILS    = %w(abuse@ academic.administrator@ accounts@ account-update@ admin@ administrator@ advice@
                               alert@ alerts@ all@ analysis@ arts@ assistant@ auto-confirm@ billing@ birmingham@
                               bizdev@ bookings@ boss@ confirm@ bot@ bristol@ bursar@ bury@ careers@ career@ ceo@
                               clerks@ contact.us@ contact@ contactus@ customercare@ customerservice@ customersupport@
                               deals@ deploy@ design@ details@ development@ digest@ discussions@ dns@ do_not_reply@
                               do-not-reply@ donotreply editor@ education@ email@ enq@ enquire@ enquires@ enquiries@
                               enquiry@ enquries@ equipment@ estate@ everyone@ facebook.com facebookappmail.com
                               facilities@ farmer@ freight@ ftp@ geico@ gen.enquiries@ general.enquiries@ general@
                               genoffice@ @googlegroups.com groups@ head@ headoffice@ headteacher@ hello@ help@
                               helpdesk@ hi@ hiredesk@ hospitality@ hostmaster@ hq@ hr@ info@ infodesk@ informatica@
                               information@ institute@ insurance@ instructor@ investorrelations@ invitations
                               jira@ jobs-listings@ jobs@ law@ london@ maintenance@ mail@ mailbox@ mailer-daemon@
                               main.office@ manager@ manchester@ marketplace-messages@ marketing@ md@ media@
                               member@ @marketplace.amazon.com members@ membership@ news@ newsletter@ nntp@ noc@
                               noreply no-reply@ notifications@ notify@ notifier@ nytdirect@ office@ officeadmin@ order@
                               feedback@ orders@ payroll@ post@ postbox@ postmaster@ pr@ president@ privacy@ property@
                               reception@ recruit@ recruitment@ renewals@ rental@ replies@ reply@ request@ reservation@
                               reservations@ root@ sales@ salesinfo@ school.office@ schooladmin@ schoolinfo@ schooloffice@
                               secretary@ security@ server@ service@ services@ ship-confirm@ slashdot.org smtp@ spam@
                               studio@ subscribe@ supervisor@ support@ technique@ theoffice@ undisclosed-recipients@
                               update@ uk-info@ usenet@ uucp@ vets@ www@ webadmin@ webmail@ webmaster@ whois@
                               yahoogroups.com builds@ ebay@)

    def initialize(domain)
      @domain = domain
    end

    # Returns an index to the email pattern that is followed by the email samples
    #  found in the Google searches.
    def pattern_index
      results = ::DistributedSearch::DistributedSearch.new.search(query)

      results['results'].each do |result|
        email = email_match(strip_html(result['content']))

        if email
          username, _domain = email.split('@')

          resolver = EmailPatternResolver.new(username)
          pattern  = resolver.pattern

          if pattern
            employee          = Employee.new(SAMPLE_FIRST_NAME, SAMPLE_LAST_NAME, SAMPLE_DOMAIN)
            resolved_username = EmailPatternResolver.name_for(SAMPLE_FIRST_NAME, SAMPLE_LAST_NAME, pattern)

            return employee.pattern_index_for(resolved_username)
          end
        end
      end

      nil
    end

    private

    def filtered?(email)
      BLACKLISTED_EMAILS.any?{|e| email =~ /#{e}/i}
    end

    def email_match(content)
      matches = content.scan(/\b\w+@#{domain}\b/i)

      matches.find {|m| filtered?(m) == false}
    end

    def query
      "contact #{domain}"
    end
  end
end
