-- libquvi-scripts
-- Copyright (C) 2011,2013  Toni Gundogdu <legatvs@gmail.com>
--
-- This file is part of libquvi-scripts <http://quvi.sourceforge.net/>.
--
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Affero General Public
-- License as published by the Free Software Foundation, either
-- version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General
-- Public License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.
--

local Guardian = {} -- Utility functions unique to this script

-- Identify the media script.
function ident(qargs)
  return {
    can_parse_url = Guardian.can_parse_url(qargs),
    domains = table.concat({'guardian.co.uk'}, ',')
  }
end

-- Parse the media properties.
function parse(qargs)
  local p = Guardian.fetch(qargs)

  qargs.duration_ms = tonumber(p:match('duration%:%s+"?(%d+)"?') or 0) * 1000

  qargs.title = p:match('"og:title" content="(.-)"') or ''

  qargs.id = (p:match('containerID%s+=%s+["\'](.-)["\']')
              or p:match('audioID%s+=%s+["\'](.-)["\']')
              or ''):match('(%d+)') or ''

  qargs.thumb_url = p:match('"thumbnail" content="(.-)"')
                      or p:match('"og:image" content="(.-)"') or ''

  qargs.streams = Guardian.iter_streams(p)

  return qargs
end

--
-- Utility functions
--

function Guardian.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)
  if t and t.scheme and t.scheme:lower():match('^https?$')
       and t.host   and t.host:lower():match('guardian%.co%.uk$')
       and t.path   and (t.path:lower():match('/video/')
                         or t.path:lower():match('/audio/'))
  then
    return true
  else
    return false
  end
end

function Guardian.fetch(qargs)
  local p = quvi.http.fetch(qargs.input_url).data
  local e = p:match('<div class="expired">.-<p>(.-)</p>.-</div>') or ''
  if #e >0 then error(e) end
  return p
end

function Guardian.iter_streams(p)
  local u = p:match('file:%s+"(.-)"')
              or error("no match: media stream URL")
  local S = require 'quvi/stream'
  return {S.stream_new(u)}
end

-- vim: set ts=2 sw=2 tw=72 expandtab: