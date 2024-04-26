function OnMsg.DataLoaded()
	PlaceObj("XTemplate", {
		__is_kind_of = "XDialog",
		group = "Zulu PDA",
		id = "HUDAReinforcmentsDialog",
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
		PlaceObj('XTemplateProperty', {
			'id', "HudaRadioHistory",
			'editor', "table",
			'translate', false,
			'Set', function(self, value)
			self.HudaRadioHistory = value
		end,
			'Get', function(self)
			return self.HudaRadioHistory
		end,
			'name', T(3633742193270817, --[[XTemplate PDAImpAnswers name]] "HudaRadioHistory"),
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
			'InitialMode', "radioactions",
			'InternalModes', "radioactions,reinforcements,mortar,mortarspacing,mortarrounds,mortarammo, mortarconfirm",
		}, {
			PlaceObj('XTemplateFunc', {
				'name', "OnDialogModeChange(self, mode, dialog)",
				'func', function(self, mode, dialog)
				XDialog.OnDialogModeChange(self, mode, dialog)

				-- ObjModified(self)

				local modeTitels = {
					radioactions = "AVAILABLE ACTIONS:",
					reinforcements = "CALL REINFORCEMENTS",
					mortar = "SELECT MORTAR SQUAD",
					mortarrounds = "NUMBER OF ROUNDS",
					mortarspacing = "SPACING",
					mortarammo = "AMMOTYPE",
					mortarconfirm = "FIREMISSION OVERVIEW"
				}

				self.idContainer.idRadioHeader[1]:SetText(Untranslated(modeTitels[mode] or "AVAILABLE ACTIONS:"))
			end,
			}),
			PlaceObj("XTemplateWindow", {
				"HAlign",
				"center",
				"VAlign",
				"center",
				"MinWidth",
				450,
				"MaxWidth",
				450,
				"MinHeight",
				370,
				"LayoutMethod",
				"VList",
				"LayoutVSpacing",
				-7
			}, {
				PlaceObj('XTemplateWindow', {
					'comment', "background rectangle",
					'__class', "XImage",
					'Dock', "box",
					'Image', "Mod/a7iPvXU/Images/radiobg.png",
				}),
				PlaceObj("XTemplateWindow", {
					'__class', "XContentTemplate",
					"Id",
					"idContainer",
					"comment",
					"content",
					"MinWidth",
					190,
					"MaxWidth",
					190,
					"MinHeight",
					195,
					"MaxHeight",
					195,
					"Margins",
					box(33, 425, 0, 0),
					"Padding",
					box(3, 3, 3, 3),
					"HAlign",
					"center",
					"VAlign",
					"top",
					"Dock",
					"box"
				}, {
					PlaceObj("XTemplateMode", {
						'mode', "radioactions",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"actionselection",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateWindow", {
								"__condition",
								function(parent, context)
									return not context.reinforcementActive and not context.mortarActive
								end,
								"Id",
								"idRadioAction",
								"Padding",
								box(0, 0, 0, 0),
								"__class",
								"XText",
								"HAlign",
								"center",
								"VAlign",
								"center",
								"Translate",
								true,
								"Clip",
								false,
								"TextStyle",
								"HUDA_Radio",
								"TextHAlign",
								"center",
								"Text",
								T(36337421932708190816, --[[XTemplate PDAImpAnswers Text]] "No actions available")
							}),
							PlaceObj("XTemplateForEach", {
								"array",
								function(parent, context)
									local array = {}

									if #context.reinforcementSquads > 0 then
										table.insert(array,
											{
												name = "REINFORCEMENTS",
												mode = "reinforcements",
												active = context
													.reinforcementActive,
												ap = context.reinforcementAp
											})
									end

									if #context.mortarSquads > 0 then
										table.insert(array,
											{
												name = "MORTAR SUPPORT",
												mode = "mortar",
												active = context
													.mortarActive,
												ap = context.mortarAp
											})
									end

									return array
								end,
								"__context",
								function(parent, context, item, i, n)
									return item
								end,
								"run_after",
								function(child, context, item, i, n, last)
									local apText = context.ap and
										Untranslated(" ") ..
										Untranslated(DivRound(context.ap, const.Scale.AP)) .. Untranslated("AP") or ""
									child.idRadioAction:SetText(Untranslated(context.name) .. apText)
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									0,
									"BorderWidth",
									1,
									"BorderColor",
									RGBA(52, 55, 61, 255),
									"MouseCursor",
									"UI/Cursors/Pda_Hand.tga",
								}, {
									PlaceObj("XTemplateWindow", {
										"Id",
										"idRadioAction",
										"Padding",
										box(6, 0, 0, 0),
										"__class",
										"XText",
										"HAlign",
										"center",
										"VAlign",
										"center",
										"Translate",
										true,
										"Clip",
										false,
										"TextStyle",
										"HUDA_Radio",
										"TextHAlign",
										"center",

									}),
									PlaceObj("XTemplateFunc", {
										"name",
										"OnMouseButtonDown(self, pos, button)",
										"func",
										function(self, pos, button)
											local dlg = GetDialog(self)

											if self.context.active then
												PlayFX("buttonPress", "start")

												dlg.HudaRadioHistory = dlg.HudaRadioHistory or {}
												table.insert(dlg.HudaRadioHistory, self.context.mode)

												dlg:SetMode(self.context.mode)
											else
												PlayFX("UIDisabledButtonPressed", "start")
											end
										end
									})
								})
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "reinforcements",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"reinforcmentslist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateForEach", {
								"array",
								function(parent, context)
									return context.reinforcementSquads
								end,
								"__context",
								function(parent, context, item, i, n)
									return item
								end,
								"run_after",
								function(child, context, item, i, n, last)
									local squad = context
									child.idSectorId:SetText(Untranslated(squad.sectorId))

									local delay = g_Combat and Untranslated(" (") .. Untranslated(squad.minDelay) ..
										Untranslated(")") or ""

									child.idSquadName:SetText(Untranslated(squad.name) .. delay)
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									5,
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
										"idSectorId",
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
										"center"
									}),
									PlaceObj("XTemplateWindow", {
										"__class",
										"XText",
										"Id",
										"idSquadName",
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
										"center"
									}),
									PlaceObj("XTemplateFunc", {
										"name",
										"OnMouseButtonDown(self, pos, button)",
										"func",
										function(self, pos, button)
											local reinforceSquad = self.context

											PlayFX("buttonPress", "start")

											local dlg = GetDialog(self)

											local squad = gv_Squads[reinforceSquad.squadId]

											HUDA_SendReinforcements(squad, squad.CurrentSector, reinforceSquad.direction,
												reinforceSquad.minDelay,
												dlg.context.unit)

											dlg:Close()
										end
									})
								}),
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "mortar",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"mortarsquadlist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateForEach", {
								"array",
								function(parent, context)
									return context.mortarSquads
								end,
								"__context",
								function(parent, context, item, i, n)
									return item
								end,
								"run_after",
								function(child, context, item, i, n, last)
									local squad = context
									child.idSectorId:SetText(Untranslated(squad.sectorId))
									child.idSquadName:SetText(Untranslated(squad.name))
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									0,
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
										"idSectorId",
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
										"center"
									}),
									PlaceObj("XTemplateWindow", {
										"__class",
										"XText",
										"Id",
										"idSquadName",
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

											dlg.HudaMortarOptions.squad = self.context

											dlg.HudaRadioHistory = dlg.HudaRadioHistory or {}
											table.insert(dlg.HudaRadioHistory, "mortarammo")

											dlg:SetMode("mortarammo")
										end
									})
								}),
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "mortarammo",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"mortarsquadlist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateForEach", {
								"array",
								function(parent, context)
									local ammoConfig = context.mortarAmmo

									local thisContext = {}

									local dlg = GetDialog(parent)

									local squad = dlg.HudaMortarOptions.squad

									for i, option in ipairs(ammoConfig) do
										if squad.mortarData.mortarAmmo[option.value] then
											local ammoOption = option

											ammoOption.amount = squad.mortarData.mortarAmmo[option.value]

											table.insert(thisContext, ammoOption)
										end
									end

									return thisContext
								end,
								"__context",
								function(parent, context, item, i, n)
									return item
								end,
								"run_after",
								function(child, context, item, i, n, last)
									child.idAmmo:SetText(Untranslated(context.name) ..
										Untranslated(" (") .. Untranslated(context.amount) .. Untranslated(")"))
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									0,
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
										"idAmmo",
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

											dlg.HudaMortarOptions.ammo = self.context.value

											dlg.HudaRadioHistory = dlg.HudaRadioHistory or {}
											table.insert(dlg.HudaRadioHistory, "mortarrounds")

											dlg:SetMode("mortarrounds")
										end
									})
								}),
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "mortarrounds",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"mortarsquadlist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateForEach", {
								"array",
								function(parent, context)
									local dlg = GetDialog(parent)

									local squad = dlg.HudaMortarOptions.squad

									local ammo = dlg.HudaMortarOptions.ammo

									local availableAmmo = squad.mortarData.mortarAmmo[ammo]


									local roundsConfig = context.mortarRounds

									local thisContext = {}

									for i, option in ipairs(roundsConfig) do
										if option.value <= availableAmmo then
											table.insert(thisContext, option)
										end
									end

									return thisContext
								end,
								"__context",
								function(parent, context, item, i, n)
									return item
								end,
								"run_after",
								function(child, context, item, i, n, last)
									child.idRounds:SetText(Untranslated(context.name))
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									0,
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

											dlg.HudaRadioHistory = dlg.HudaRadioHistory or {}
											table.insert(dlg.HudaRadioHistory, "mortarspacing")

											dlg:SetMode("mortarspacing")
										end
									})
								}),
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "mortarspacing",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"mortarsquadlist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
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
								end
							}, {
								PlaceObj("XTemplateWindow", {
									"__class",
									"XContentTemplate",
									"LayoutMethod",
									"HList",
									"LayoutHSpacing",
									0,
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
										"idSpacing",
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

											dlg.HudaRadioHistory = dlg.HudaRadioHistory or {}
											table.insert(dlg.HudaRadioHistory, "mortarconfirm")

											dlg:SetMode("mortarconfirm")
										end
									})
								}),
							})
						})
					}),
					PlaceObj("XTemplateMode", {
						'mode', "mortarconfirm",
					}, {
						PlaceObj("XTemplateWindow", {
							"comment",
							"mortarsquadlist",
							"LayoutMethod",
							"VList",
							"LayoutVSpacing",
							3,
						}, {
							PlaceObj("XTemplateWindow", {
								"__class",
								"XText",
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
								"TextVAlign",
								"center",
								"OnLayoutComplete",
								function(self, layout)
									local dlg = GetDialog(self)

									local mortarOptions = dlg.HudaMortarOptions

									self:SetText(T { 3633742193270818, "AMMO: <ammo>\nROUNDS: <rounds>\nSPACING: <spacing>",
										ammo = Untranslated(table.find_value(dlg.context.mortarAmmo, "value", mortarOptions.ammo).name),
										rounds = Untranslated(table.find_value(dlg.context.mortarRounds, "value", mortarOptions.rounds).name),
										spacing = Untranslated(table.find_value(dlg.context.mortarSpacing, "value", mortarOptions.spacing).name)
									})
								end
							}),
							PlaceObj("XTemplateWindow", {
								"__class",
								"XContentTemplate",
								"LayoutMethod",
								"HList",
								"LayoutHSpacing",
								0,
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

										local attackOptions = {
											ammo = dlg.HudaMortarOptions.ammo,
											rounds = dlg.HudaMortarOptions.rounds,
											spacing = dlg.HudaMortarOptions.spacing,
											mortar = dlg.HudaMortarOptions.squad.mortarData.mortar,
											unit = dlg.HudaMortarOptions.squad.mortarData.mortarUnit
										}

										CombatActions.BombardRemote.attackOptions = attackOptions

										CombatActionAttackStart(CombatActions.BombardRemote, { SelectedObj }, {},
											"IModeCombatAreaAim")

										dlg:Close()
									end
								})
							})
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
							box(0, 0, 0, 1),
							"Text",
							Untranslated("AVAILABLE ACTIONS:")
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
							"OnLayoutComplete",
							function(self, layout)
								local dlg = GetDialog(self)

								if dlg.Mode and dlg.Mode ~= dlg.InitialMode then
									self:SetVisible(true)
								else
									self:SetVisible(false)
								end
							end,
							"__class",
							"XText",
							"HAlign",
							"left",
							"VAlign",
							"center",
							"Clip",
							false,
							"Dock",
							"left",
							"TextStyle",
							"HUDA_Radio",
							"Translate",
							true,
							"TextHAlign",
							"center",
							"TextVAlign",
							"center",
							"Text",
							Untranslated("back")
						}, {
							PlaceObj("XTemplateFunc", {
								"name",
								"OnMouseButtonDown(self, pos, button)",
								"func",
								function(self, pos, button)
									local dlg = GetDialog(self)

									PlayFX("buttonPress", "start")

									local lastMode = dlg.HudaRadioHistory and dlg.HudaRadioHistory
										[#dlg.HudaRadioHistory]

									if lastMode and lastMode[1] ~= "" then
										table.remove(dlg.HudaRadioHistory, #dlg.HudaRadioHistory)
										dlg:SetMode(#dlg.HudaRadioHistory > 0 and dlg.HudaRadioHistory
											[#dlg.HudaRadioHistory] or dlg.InitialMode)
									end
								end
							})
						}),
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
