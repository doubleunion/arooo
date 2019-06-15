require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
  username { "user#{sn}" }
  email { "#{sn}@example.com" }
  # Attributes here
end

User.blueprint(:visitor)    { state { 'visitor'    } }
User.blueprint(:applicant)  { state { 'applicant'  } }
User.blueprint(:member)     { state { 'member'     } }
User.blueprint(:key_member) { state { 'key_member' } }
User.blueprint(:voting_member) { state { 'voting_member' } }

Application.blueprint do
end

Application.blueprint(:with_user) { user { create(:user, state: :applicant) } }

Vote.blueprint do
  value { true }
end

Comment.blueprint do
  # Attributes here
end
