local input = require 'mp.input'

function prompt_for_url()
    input.get({
        prompt = "Paste URL to play: ",
        submit = function(text)
            -- Trim spaces if any
            text = text:match("^%s*(.-)%s*$")
            if text ~= "" then
                -- 'replace' drops the current video and plays the new link
                mp.commandv("loadfile", text, "replace")
            end
        end
    })
end

-- Register the function so we can bind a key to it
mp.add_key_binding(nil, "open-url-prompt", prompt_for_url)
