module ForemanOpenscap
  class XccdfRule < ActiveRecord::Base    
    # This is just an enumeration of ID's that have been found in the XCCDF contents uploaded
    # to ForemanOpenscap.
    #
    # Each Xccdf:Rule may have contain other data useful to users (Title, idents, and description,
    # ...). These however needs to be carried by different entity (XccdfContentRule presumably).
    # That is because different XCCDF contents may refer to the very same ID, even though it may
    # have slightly different meaning in the context of given policy.
    #
    # There is still value in being able to enumerate the rules regardless of the policy. As we
    # can expect that when the ID matches, most of the things will match as well (consider
    # different version of the same policy). User may then want to search the results for a given
    # rule.
    #
    validates :xid, :presence => true, :uniqueness => true
  end
end
