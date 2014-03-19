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
    module Host

      class WaitUntilPuppetRunCompletes < Actions::Base

        middleware.use Actions::Staypuft::Middleware::AsCurrentUser
        include Dynflow::Action::Polling

        def plan(host_id)
          plan_self host_id: host_id
        end

        def external_task
          output[:status]
        end

        def done?
          external_task
        end

        private
        def invoke_external_task
          nil
        end

        def external_task=(external_task_data)
          output[:status] = external_task_data
        end

        def poll_external_task
          puppet_complete?(input[:host_id])
        end

        def poll_interval
          5
        end

        def puppet_complete?(host_id)
          host = ::Host.find(host_id)
          host.reports.order("reported_at DESC").each do |report|
            if report_change?(report)
              if report_failed?(report)
                fail(::Staypuft::Exception, "Latest Puppet Run Contains "\
                                            "Failures for Host: #{host.id}")
              else
                return true
                
              end
            end
          end
          false
        end

        def report_change?(report)
          report.status["applied"] > 0
        end

        def report_failed?(report)
          report.status["failed"] > 0
        end
      end
    end
  end
end