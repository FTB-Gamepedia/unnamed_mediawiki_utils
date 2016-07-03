require 'mediawiki/butt'

module MediaWiki
  class Utils
    # Creates a new Utils object and logs in.
    # @param url [String] API endpoint
    # @param (see #login)
    # @param opts [Hash] See MediaWiki::Butt documentation.
    def initialize(url, user, pass, opts = {})
      @butt = MediaWiki::Butt.new(url, opts)
      login(user, pass)
    end

    # Logs into the wiki.
    # @param user [String] username
    # @param pass [String] password
    # @return [void]
    def login(user, pass)
      @butt.login(user, pass)
      @user = user
      @pass = pass
    end

    # Moves a category, and modifies its members to reflect that move.
    # @param old_cat [String] Old category name
    # @param new_cat [String] New category name
    # @param summary [String] The edit summary. Defaults to "Move #{old_cat} to #{new_cat}".
    # @return [Boolean] Whether all of the edits were successful.
    # @return [NilClass] If the old category doesn't exist or the new one does.
    # @return [Fixnum] If the creation of the new category or the deletion of the old one failed.
    # @todo implement proper error handling in MediaWiki::Butt so we don't have such crappy return values.
    # @todo generify
    def move_category(old_cat, new_cat, summary = nil)
      old_cat_ns = namespacify('Category', old_cat)
      new_cat_ns = namespacify('Category', new_cat)
      summary = "Move #{old_cat} to #{new_cat}" unless summary

      old_cat_contents = @butt.get_text(old_cat_ns)
      new_cat_contents = @butt.get_text(new_cat_ns)

      return if old_cat_contents.nil? || !new_cat_contents.nil?

      create = @butt.create_page(new_cat_ns, old_cat_contents, summary)
      return create unless create.is_a?(Fixnum)

      delete = @butt.delete(old_cat_ns, summary)
      return delete unless delete

      # TODO: Continue
      members = @butt.get_category_members(old_cat_ns, 5000)
      success = true
      members.each do |member|
        member_content = @butt.get_text(member)
        next if member_content.nil?
        member_content.gsub!(old_cat_ns, new_cat_ns)
        member_content.gsub!(/\{\{[Cc]\|#{old_cat}\}\}/, "{{C|#{new_cat}}}")
        edit = @butt.edit(member, member_content, true, true, summary)
        success = false unless edit.is_a?(Fixnum)
      end

      success
    end

    # Returns the string with the namespace prepended to it if needed. For example, namespacify('Category', 'Help')
    # and namespacify('Category', 'Category:Help') yield 'Category:Help'
    # @param namespace [String] Desired namespace prefix
    # @param string [String] Page name
    # @return [String] Namespaced page title.
    def namespacify(namespace, string)
      string.downcase =~ /^#{namespace.downcase}:/ ? string.capitalize : "#{namespace.capitalize}:#{string}"
    end

    private

    def refresh_login
      # TODO: Some way to check if we are currently logged in as anything.
      @butt.login(@user, @pass)
    end
  end
end
