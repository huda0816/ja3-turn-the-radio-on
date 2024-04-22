function OnMsg.DataLoaded()
	PlaceObj("XTemplate", {
		__is_kind_of = "XDialog",
		group = "Zulu PDA",
		id = "HUDAMortarDialog",
		PlaceObj('XTemplateProperty', {
			'id', "HudaMortarOptions",
			'editor', "table",
			'translate', false,
			'Set', function(self, value)
			self.HudaMortarOptions = value
		end,
			'Get', function(self)
			return self.HudaMortarOptions
		end,
			'name', T(3633742193270816, --[[XTemplate PDAImpAnswers name]] "HudaMortarOptions"),
		}),
		PlaceObj("XTemplateWindow", {
			'__class', "XDialog",
			"Id",
			"idMain",
			"HostInParent",
			true,
			'ZOrder', 10,
			'HandleMouse', true,
			'Background', RGBA(0, 0, 0, 130),
			'DrawOnTop', true,
			'ContextUpdateOnOpen', true,
		}, {
			PlaceObj("XTemplateWindow", {
				"HAlign",
				"center",
				"VAlign",
				"center",
				"MinWidth",
				450,
				"MaxWidth",
				450,
				"LayoutMethod",
				"VList",
				"LayoutVSpacing",
				-7
			}, {
				PlaceObj('XTemplateWindow', {
					'comment', "background rectangle",
					'__class', "XImage",
					'Dock', "box",
					'Image', "Mod/a7iPvXU/Images/mortartargeting.png",
					'ImageFit', "width",
				}),
				PlaceObj("XTemplateWindow", {
					'__class', "XContentTemplate",
					"Id",
					"idContainer",
					"comment",
					"content",
					"MinWidth",
					292,
					"MaxWidth",
					292,
					"MinHeight",
					225,
					"MaxHeight",
					225,
					"Margins",
					box(0, 150, 0, 0),
					"Padding",
					box(5, 5, 5, 5),
					"HAlign",
					"center",
					"VAlign",
					"top",
					"Dock",
					"box",
					"LayoutMethod",
					"VList",
					"LayoutVSpacing",
					6,
				}, {

					PlaceObj("XTemplateWindow", {
						"comment",
						"roundselection",
						"LayoutMethod",
						"HList",
						"LayoutHSpacing",
						5,
					}, {
						PlaceObj("XTemplateWindow", {
							"__class",
							"XText",
							"HAlign",
							"center",
							"VAlign",
							"center",
							"Clip",
							false,
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"TextHAlign",
							"left",
							"TextVAlign",
							"center",
							"Margins",
							box(0, 0, 0, 1),
							"MinWidth",
							66,
							"MaxWidth",
							66,
							"Text",
							Untranslated("ROUNDS")
						}),
						PlaceObj("XTemplateForEach", {
							"array",
							function(parent, context)
								-- local dlg = GetDialog(parent)

								-- local squad = dlg.HudaMortarOptions.squad

								-- local ammo = dlg.HudaMortarOptions.ammo

								-- local availableAmmo = squad.mortarData.mortarAmmo[ammo]


								-- local roundsConfig = context.mortarRounds

								-- local thisContext = {}

								-- for i, option in ipairs(roundsConfig) do
								-- 	if option.value <= availableAmmo then
								-- 		table.insert(thisContext, option)
								-- 	end
								-- end

								return context.mortarRounds
							end,
							"__context",
							function(parent, context, item, i, n)
								return item
							end,
							"run_after",
							function(child, context, item, i, n, last)
								child.idRounds:SetText(Untranslated(context.name))

								local dlg = GetDialog(child)

								if (not dlg.HudaMortarOptions or not dlg.HudaMortarOptions.rounds) and i == 1 or dlg.HudaMortarOptions and dlg.HudaMortarOptions.rounds == context.value then
									child.Background = RGBA(52, 55, 61, 255)
									child.idRounds:SetTextStyle("HUDA_Radio_Bright")
								else
									child.Background = RGBA(0, 0, 0, 0)
									child.idRounds:SetTextStyle("HUDA_Radio")
								end
							end
						}, {
							PlaceObj("XTemplateWindow", {
								"__class",
								"XContentTemplate",
								"MinWidth",
								24,
								"MaxWidth",
								24,
								"MinHeight",
								24,
								"MaxHeight",
								24,
								"BorderWidth",
								1,
								"BorderColor",
								RGBA(52, 55, 61, 255),
								"MouseCursor",
								"UI/Cursors/Pda_Hand.tga",
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XText",
									"Id",
									"idRounds",
									"Clip",
									false,
									"TextStyle",
									"HUDA_Radio",
									"Translate",
									true,
									"TextHAlign",
									"center",
									"TextVAlign",
									"center"
								}),
								PlaceObj("XTemplateFunc", {
									"name",
									"OnMouseButtonDown(self, pos, button)",
									"func",
									function(self, pos, button)
										local dlg = GetDialog(self)

										PlayFX("buttonPress", "start")

										dlg.HudaMortarOptions = dlg.HudaMortarOptions or {}

										dlg.HudaMortarOptions.rounds = self.context.value

										ObjModified(dlg:GetContext())
									end
								})
							}),
						})

					}),
					PlaceObj("XTemplateWindow", {
						"comment",
						"spacingselection",
						"LayoutMethod",
						"HList",
						"LayoutHSpacing",
						5,
					}, {
						PlaceObj("XTemplateWindow", {
							"__class",
							"XText",
							"HAlign",
							"center",
							"VAlign",
							"center",
							"Clip",
							false,
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"TextHAlign",
							"left",
							"TextVAlign",
							"center",
							"Margins",
							box(0, 0, 0, 1),
							"MinWidth",
							66,
							"MaxWidth",
							66,
							"Text",
							Untranslated("SPACING")
						}),
						PlaceObj("XTemplateForEach", {
							"array",
							function(parent, context)
								return context.mortarSpacing
							end,
							"__context",
							function(parent, context, item, i, n)
								return item
							end,
							"run_after",
							function(child, context, item, i, n, last)
								child.idSpacing:SetText(Untranslated(context.name))

								local dlg = GetDialog(child)

								if (not dlg.HudaMortarOptions or not dlg.HudaMortarOptions.spacing) and i == 1 or dlg.HudaMortarOptions and dlg.HudaMortarOptions.spacing == context.value then
									child.Background = RGBA(52, 55, 61, 255)
									child.idSpacing:SetTextStyle("HUDA_Radio_Bright")
								else
									child.Background = RGBA(0, 0, 0, 0)
									child.idSpacing:SetTextStyle("HUDA_Radio")
								end
							end
						}, {
							PlaceObj("XTemplateWindow", {
								"__class",
								"XContentTemplate",
								"MinHeight",
								24,
								"MaxHeight",
								24,
								"BorderWidth",
								1,
								"BorderColor",
								RGBA(52, 55, 61, 255),
								"Padding",
								box(5, 0, 5, 0),
								"MouseCursor",
								"UI/Cursors/Pda_Hand.tga",
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XText",
									"Id",
									"idSpacing",
									"Clip",
									false,
									"TextStyle",
									"HUDA_Radio",
									"Translate",
									true,
									"TextHAlign",
									"center",
									"TextVAlign",
									"center"
								}),
								PlaceObj("XTemplateFunc", {
									"name",
									"OnMouseButtonDown(self, pos, button)",
									"func",
									function(self, pos, button)
										local dlg = GetDialog(self)

										PlayFX("buttonPress", "start")

										dlg.HudaMortarOptions = dlg.HudaMortarOptions or {}

										dlg.HudaMortarOptions.spacing = self.context.value

										ObjModified(dlg:GetContext())
									end
								})
							}),
						})
					}),
					PlaceObj("XTemplateWindow", {
						"__class",
						"XContentTemplate",
						"Margins",
						box(0, 5, 0, 0),
						"BorderWidth",
						1,
						"BorderColor",
						RGBA(52, 55, 61, 255),
						"MouseCursor",
						"UI/Cursors/Pda_Hand.tga",
					}, {
						PlaceObj("XTemplateWindow", {
							"__class",
							"XText",
							"Id",
							"idConfirm",
							"Margins",
							box(0, 0, 0, 0),
							"VAlign",
							"center",
							"Clip",
							false,
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"Dock",
							"top",
							"TextHAlign",
							"center",
							"TextVAlign",
							"center",
							"Text",
							Untranslated("CONFIRM")
						}),
						PlaceObj("XTemplateFunc", {
							"name",
							"OnMouseButtonDown(self, pos, button)",
							"func",
							function(self, pos, button)
								local dlg = GetDialog(self)

								PlayFX("buttonPress", "start")

								CombatActions.Bombard.bombard_shots = dlg.HudaMortarOptions and
								dlg.HudaMortarOptions.rounds or 1
								CombatActions.Bombard.bombard_radius = dlg.HudaMortarOptions and
								dlg.HudaMortarOptions.spacing or 0

								CombatActionAttackStart(CombatActions.Bombard, { SelectedObj }, {},
									"IModeCombatAreaAim")

								dlg:Close()
							end
						})
					}),
					PlaceObj("XTemplateWindow", {
						"Id",
						"idRadioHeader",
						"LayoutMethod",
						"HList",
						"LayoutHSpacing",
						0,
						"Dock",
						"top",
					}, {
						PlaceObj("XTemplateWindow", {
							"__class",
							"XText",
							"HAlign",
							"center",
							"VAlign",
							"center",
							"Clip",
							false,
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"TextHAlign",
							"center",
							"TextVAlign",
							"center",
							"Margins",
							box(0, 0, 0, 5),
							"Text",
							Untranslated("SETUP MORTAR STRIKE")
						})
					}),
					PlaceObj("XTemplateWindow", {
						"LayoutMethod",
						"HList",
						"LayoutHSpacing",
						0,
						"MouseCursor",
						"UI/Cursors/Pda_Hand.tga",
						"Dock",
						"bottom",
					}, {
						PlaceObj("XTemplateWindow", {
							"__class",
							"XText",
							"HAlign",
							"right",
							"VAlign",
							"center",
							"Clip",
							false,
							"Dock",
							"right",
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"TextHAlign",
							"center",
							"TextVAlign",
							"center",
							"Text",
							Untranslated("close")
						}, {
							PlaceObj("XTemplateFunc", {
								"name",
								"OnMouseButtonDown(self, pos, button)",
								"func",
								function(self, pos, button)
									local dlg = GetDialog(self)
									PlayFX("buttonPress", "start")
									dlg:Close()
								end
							})
						})
					})
				})
			})
		})
	})
end
