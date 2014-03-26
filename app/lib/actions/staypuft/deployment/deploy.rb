#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Staypuft
    module Deployment
      # just a mock, models and seeds are not ready yet
      class Deploy < Actions::Base

        middleware.use Actions::Staypuft::Middleware::AsCurrentUser

        def plan(deployment)
          Type! deployment, ::Staypuft::Deployment

          role_id_hostgroup_map = deployment.child_hostgroups.includes(:role).
              inject({}) { |hash, host_group| hash.update host_group.role.id => host_group }
          ordered_hostgroups    = deployment.layout.roles.map { |role| role_id_hostgroup_map[role.id] }

          plan_action Hostgroup::OrderedDeploy, ordered_hostgroups
        end
      end
    end
  end
end
