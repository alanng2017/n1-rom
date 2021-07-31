local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b

--Set Default value
default_firmware_repo="cocokfeng/n1-rom"
local amlogic_firmware_repo = luci.sys.exec("uci get amlogic.config.amlogic_firmware_repo 2>/dev/null") or default_firmware_repo

default_firmware_tag="n1_lede"
local amlogic_firmware_tag = luci.sys.exec("uci get amlogic.config.amlogic_firmware_tag 2>/dev/null") or default_firmware_tag

default_firmware_suffix=".img.gz"
local amlogic_firmware_suffix = luci.sys.exec("uci get amlogic.config.amlogic_firmware_suffix 2>/dev/null") or default_firmware_suffix

default_kernel_path="n1/kernel"
local amlogic_kernel_path = luci.sys.exec("uci get amlogic.config.amlogic_kernel_path 2>/dev/null") or default_kernel_path
--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false


--SimpleForm for Check
b = SimpleForm("amlogic", translate("在线下载更新"), nil)
b.description = translate("( 设置要更新的固件版本<多功能版: n1_lede > 、<精简自用1:n1_zy1 > 、<精简自用2: n1_zy2 > 、<精简自用3: n1_zy3 >  )")
b.reset = false
b.submit = false

s = b:section(SimpleSection, "", "")


--1.Set OpenWrt Releases Tag Keywords
o = s:option(Value, "firmware_tag", translate("选择在线更新固件版本:"))
o.rmempty = true
o.default = amlogic_firmware_tag
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_firmware_tag = default_firmware_tag
	else
        --self.description = translate("OpenWrt Releases Tag Keywords:") .. value
        amlogic_firmware_tag = value
	end
end

--2.Save button
o = s:option(Button, "", translate("Save Config:"))
o.template = "amlogic/other_button"
o.render = function(self, section, scope)
	self.section = true
	scope.display = ""
	self.inputtitle = translate("Save")
	self.inputstyle = "apply"
	Button.render(self, section, scope)
end
o.write = function(self, section, scope)
	luci.sys.exec("uci set amlogic.config.amlogic_firmware_tag=" .. amlogic_firmware_tag .. " 2>/dev/null")
	luci.sys.exec("uci commit amlogic 2>/dev/null")
	http.redirect(DISP.build_url("admin", "system", "amlogic", "check"))
	--self.description = "amlogic_firmware_repo: " .. amlogic_firmware_repo
end

b:section(SimpleSection).template  = "amlogic/other_check"

return m, b