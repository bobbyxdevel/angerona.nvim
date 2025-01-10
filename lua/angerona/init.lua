local M = {}

local http = require('plenary.curl')

M.api_key = nil
M.base_url = nil

function M.setup(user_config)
    M.api_key = user_config.api_key or M.api_key
    M.base_url = user_config.base_url or M.base_url

    vim.api.nvim_create_user_command('CreateRedmineTask', function()
        local project_id = vim.fn.input("Project ID: ")
        local subject = vim.fn.input("Subject: ")
        local description = vim.fn.input("Description: ")
        local parent_id = vim.fn.input("Parent Ticket ID (optional): ")

        -- Call the function to create a task
        M.create_task(project_id, subject, description, parent_id)
    end, { desc = "Create a Redmine task via REST API" })
end

function M.create_task(project_id, subject, description, parent_id)
    local url = M.base_url .. "/issues.json"
    local headers = {
        ["Content-Type"] = "application/json",
        ["X-Redmine-API-Key"] = M.api_key,
    }
    local body = {
        issue = {
            project_id = project_id,
            subject = subject,
            description = description,
            tracker_id = 16, -- Tracker ID for tasks
        }
    }

    -- Include parent ID if provided
    if parent_id and parent_id ~= "" then
        body.issue.parent_issue_id = tonumber(parent_id)
    end

    -- Make the HTTP POST request
    local response = http.post(url, {
        headers = headers,
        body = vim.fn.json_encode(body),
    })

    -- Check the response status and provide feedback
    if response.status == 201 then
        vim.notify("Task created successfully!", vim.log.levels.INFO)
    else
        vim.notify("Failed to create task: " .. (response.body or "No response"), vim.log.levels.ERROR)
    end
end

return M
