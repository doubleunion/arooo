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
  # Attributes here
end

User.blueprint(:visitor)    { state { 'visitor'    } }
User.blueprint(:applicant)  { state { 'applicant'  } }
User.blueprint(:member)     { state { 'member'     } }
User.blueprint(:key_member) { state { 'key_member' } }
