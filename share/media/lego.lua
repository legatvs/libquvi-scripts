-- libquvi-scripts
-- Copyright (C) 2013  Toni Gundogdu <legatvs@gmail.com>
-- Copyright (C) 2012  Ross Burton <ross@burtonini.com>
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

local Lego = {} -- Utility functions unique to this script

-- Identify the media script.
function ident(qargs)
  return {
    can_parse_url = Lego.can_parse_url(qargs),
    domains = table.concat({'city.lego.com'}, ',')
  }
end

-- Parse media properties.
function parse(qargs)
  local p = quvi.http.fetch(qargs.input_url).data

  local d = p:match('FirstVideoData = (.-);')
              or error('no match: FirstVideoData')

  local J = require 'json'
  local j = J.decode(d)

  qargs.id = j['LikeObjectGuid'] or '' -- Lack of a better one.

  qargs.title = j['Name'] or ''

  Lego.parse_thumb_url(qargs, p)

  qargs.streams = Lego.iter_streams(j)

  return qargs
end

--
-- Utility functions.
--

function Lego.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)
  if t and t.scheme and t.scheme:lower():match('^http$')
       and t.host   and t.host:lower():match('^city%.lego%.com$')
       and t.path   and t.path:lower():match('/%w+%-%w+/movies/')
  then
    return true
  else
    return false
  end
end

function Lego.iter_streams(j)
  local v = j['VideoHtml5'] or error('no match: VideoHtml5')
  local u = v['Url'] or error('no match: media stream URL')
  local S = require 'quvi/stream'
  return {S.stream_new(u)}
end

function Lego.parse_thumb_url(qargs, p)
  local t = {'thumbNavigation.+', '<img src="(.-)" alt="',qargs.title, '"/>',}
  qargs.thumb_url = p:match(table.concat(t,'') or '')
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
