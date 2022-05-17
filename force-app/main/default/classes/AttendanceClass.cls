public class AttendanceClass {
    public static void updateVolunteerName(List<Attendance__c> newList, Map<id, Attendance__c> oldMap){
        Set<Id> volIds = new Set<Id>();
        if(oldMap != null){
            for(Attendance__c att : newList){
            	if(oldMap.get(att.id) != null){
                    if( att.Assigned_Volunteer__c <> oldMap.get(att.id).Assigned_Volunteer__c && att.Assigned_Volunteer__c <> null){
                        volIds.add(att.Assigned_Volunteer__c);
                    }
                }
                if(att.Contact__c == null){
                    if( att.Assigned_Volunteer__c <> null)volIds.add(att.Assigned_Volunteer__c);
                }
            }
		}else{
            for(Attendance__c att : newList){
                if(att.Assigned_Volunteer__c != null){
                    volIds.add(att.Assigned_Volunteer__c);
            	}
            }
        }
        if(volIds.size() > 0){
            Map<Id, Assigned_Volunteer__c> volMap = New Map<id, Assigned_Volunteer__c>([SELECT Id, Contact__c FROM Assigned_Volunteer__c WHERE Id IN :volIds]);
            
            for(Attendance__c att : newList){
                if(oldMap != null && oldMap.get(att.id) != null){
                    if(att.Assigned_Volunteer__c <> oldMap.get(att.id).Assigned_Volunteer__c){
                        att.Contact__c = volMap.get(att.Assigned_Volunteer__c).Contact__c;
                    }
                    if(att.Contact__c == null){
                        att.Contact__c = volMap.get(att.Assigned_Volunteer__c).Contact__c;
                    }
                }else{
                    if(att.Assigned_Volunteer__c != null){
                        att.Contact__c = volMap.get(att.Assigned_Volunteer__c).Contact__c;
                    }
                }
            }
        }
    }
    
    public static void setLastAssignmentDate(List<Attendance__c> newList){
		//Last_Assignment_Date__c
		system.debug('=============setLastAssignmentDate===============');
		Set<Id> contIds = new Set<Id>();
        for(Attendance__c att : newList){
            if(att.Contact__c != null){
                contIds.add(att.Contact__c);
            }
        	
    	}
        if(contIds.size() > 0){
            system.debug('=============contIds==============='+contIds.size());
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Last_Assignment_Date__c, Volunteer_Status__c, Resignation_Date__c, Volunteer__c FROM Contact WHERE Id IN :contIds]);
            List<Contact> cList = new List<Contact>();
            for(Attendance__c att : newList){
                if(contactMap != null && contactMap.get(att.Contact__c) != null){
                //Contact c = contactMap.get(att.Contact__c);
                Date lastAssignmentDate = contactMap.get(att.Contact__c).Last_Assignment_Date__c;
                if(lastAssignmentDate == null || att.Checked_In__c.date() > lastAssignmentDate){
                    Contact c = contactMap.get(att.Contact__c);
                    c.Last_Assignment_Date__c = att.Checked_In__c.date();
                    if(!c.Volunteer__c){
                        c.Volunteer__c = true;
                    }
                    if(c.Volunteer_Status__c == 'Resigned'){
                        c.Resignation_Date__c = null;
                    }
                    cList.add(c);
                }
                /*else if(att.Checked_In__c.date() > lastAssignmentDate){
                    Contact c = contactMap.get(att.Contact__c);
                    c.Last_Assignment_Date__c = att.Checked_In__c.date();
                    cList.add(c);
                    system.debug('=============contact.Last_Assignment_Date__c==============='+c.Last_Assignment_Date__c);
                }*/
            }
            update(cList);
            }
            
        }
    }
    
    public static void calcuateVolunteerHours(List<Attendance__c> newList, Map<id, Attendance__c> oldMap){
        Set<Id> contIds = new Set<Id>();
        Set<Id> orgIds = new Set<Id>();
        if(oldMap != null){
            if(newList != null){
                for(Attendance__c att : newList){
                    if(oldMap.get(att.id) != null){
                        if(att.Checked_Out__c <> oldMap.get(att.id).Checked_Out__c || att.Checked_In__c <> oldMap.get(att.id).Checked_In__c || att.Validated__c <> oldMap.get(att.id).Validated__c){
                            if(att.Contact__c != null){
                                contIds.add(att.Contact__c);
                            }/*else if(att.Organisation_Name__c != null){
                                orgIds.add(att.Organisation_Name__c);
                            }*/
                        }
                        if(att.Contact__c <> oldMap.get(att.Id).Contact__c){
                            contIds.add(att.Contact__c);
                            contIds.add(oldMap.get(att.Id).Contact__c);
                        }/*else if(att.Organisation_Name__c  <> oldMap.get(att.Id).Organisation_Name__c){
                            orgIds.add(att.Organisation_Name__c);
                            orgIds.add(oldMap.get(att.Id).Organisation_Name__c);
                        }*/
                    }
            	}
            }else{
                for(Attendance__c att : oldMap.values()){
                    if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                        if(att.Contact__c != null){
                            contIds.add(att.Contact__c);
                        }/*else if(att.Organisation_Name__c != null){
                            orgIds.add(att.Organisation_Name__c);
                        }*/
                    }
            	}
            }
        }else{
            for(Attendance__c att : newList){
                if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                    if(att.Contact__c != null){
                        contIds.add(att.Contact__c);
                    }/*else if(att.Organisation_Name__c != null){
                        orgIds.add(att.Organisation_Name__c);
                    }*/
                }
            }
        }
        system.debug('====ericca debug=====contIds:'+ contIds);
        if(contIds != null){
            List<Contact> contactList = [SELECT id, Name, Total_Volunteering_Hours__c FROM Contact WHERE Id IN :contIds];
            for(Contact c : contactList){
                system.debug('====ericca debug 0=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                if(newList != null){
                    for(Attendance__c att : newList){
                        Date cekout = Date.newInstance(att.Checked_Out__c.year(), att.Checked_Out__c.month(), att.Checked_Out__c.day());
                        Date cekin = Date.newInstance(att.Checked_In__c.year(), att.Checked_In__c.month(), att.Checked_In__c.day()); 
                        Long daysbetween = cekin.daysBetween(cekout) * 24 * 60;
                        Long min1 = daysbetween + (att.Checked_Out__c.hour() * 60 + att.Checked_Out__c.minute()) - (att.Checked_In__c.hour() * 60 + att.Checked_In__c.minute()); 
                        if(att.Contact__c == c.Id){
                            if(oldMap != null && oldMap.get(att.id) != null && (att.Contact__c != oldMap.get(att.id).Contact__c || att.Checked_Out__c <> oldMap.get(att.id).Checked_Out__c || att.Validated__c <> oldMap.get(att.id).Validated__c)){
                                // when update
                                if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                                    c.Total_Volunteering_Hours__c = c.Total_Volunteering_Hours__c == null ? 0 + min1 : c.Total_Volunteering_Hours__c + min1;
                                    system.debug('====ericca debug 1 =====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                                }
                                
                                if(oldMap.get(att.id).Checked_In__c != null && oldMap.get(att.id).Checked_Out__c != null && oldMap.get(att.id).Validated__c && att.Contact__c == oldMap.get(att.id).Contact__c ){
                                    Date cekout0 = Date.newInstance(oldMap.get(att.id).Checked_Out__c.year(), oldMap.get(att.id).Checked_Out__c.month(), oldMap.get(att.id).Checked_Out__c.day());
                        			Date cekin0 = Date.newInstance(oldMap.get(att.id).Checked_In__c.year(), oldMap.get(att.id).Checked_In__c.month(), oldMap.get(att.id).Checked_In__c.day()); 
                                    Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60;
                                    Long min0 = daysbetween0 + (oldMap.get(att.id).Checked_Out__c.hour() * 60 + oldMap.get(att.id).Checked_Out__c.minute()) - (oldMap.get(att.id).Checked_In__c.hour() * 60 + oldMap.get(att.id).Checked_In__c.minute()); 
                                    c.Total_Volunteering_Hours__c = c.Total_Volunteering_Hours__c == null ? 0 : c.Total_Volunteering_Hours__c - min0;
                                    system.debug('====ericca debug 2=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                                }     
                            }else{ // when insert
                                if(oldMap == null || oldMap.get(att.Id) == null){
                                    if(att.Checked_In__c != null && att.Checked_Out__c != null  && att.Validated__c){
                                        c.Total_Volunteering_Hours__c = c.Total_Volunteering_Hours__c == null ? 0 + min1 : c.Total_Volunteering_Hours__c + min1;
                                        system.debug('====ericca debug 3=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                                    }
                                }
                                
                            }
                        }else if(oldMap !=null && oldMap.get(att.id) != null && att.Contact__c != oldMap.get(att.id).Contact__c && oldMap.get(att.id).Contact__c == c.Id){
                            if(oldMap.get(att.id).Checked_In__c != null && oldMap.get(att.id).Checked_Out__c != null && oldMap.get(att.id).Validated__c){
                                Date cekout0 = Date.newInstance(oldMap.get(att.id).Checked_Out__c.year(), oldMap.get(att.id).Checked_Out__c.month(), oldMap.get(att.id).Checked_Out__c.day());
                                Date cekin0 = Date.newInstance(oldMap.get(att.id).Checked_In__c.year(), oldMap.get(att.id).Checked_In__c.month(), oldMap.get(att.id).Checked_In__c.day()); 
                                Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60 ;
                                Long min0 = daysbetween0 + (oldMap.get(att.id).Checked_Out__c.hour() * 60 + oldMap.get(att.id).Checked_Out__c.minute()) - (oldMap.get(att.id).Checked_In__c.hour() * 60 + oldMap.get(att.id).Checked_In__c.minute()); 
                                c.Total_Volunteering_Hours__c = c.Total_Volunteering_Hours__c == null ? 0 : c.Total_Volunteering_Hours__c - min0;
                                system.debug('====ericca debug 4=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                            }
                        }
                    }
                }else{
                    for(Attendance__c att : oldMap.values()){
                        if(att.Contact__c == c.Id){
                            if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                                Date cekout0 = Date.newInstance(att.Checked_Out__c.year(), att.Checked_Out__c.month(), att.Checked_Out__c.day());
                                Date cekin0 = Date.newInstance(att.Checked_In__c.year(), att.Checked_In__c.month(), att.Checked_In__c.day()); 
                                Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60 ;
                                Long min0 = daysbetween0 + (att.Checked_Out__c.hour() * 60 + att.Checked_Out__c.minute()) - (att.Checked_In__c.hour() * 60 + att.Checked_In__c.minute()); 
                                c.Total_Volunteering_Hours__c = c.Total_Volunteering_Hours__c == null ? 0 : c.Total_Volunteering_Hours__c - min0;
                                system.debug('====ericca debug 5=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
                            }
                        }
                    }
                }
                system.debug('====ericca debug 6=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Total_Volunteering_Hours__c);
            }
            update(contactList);
        }
        /*if(orgIds != null){
            List<Account> accountList = [SELECT id, Name, Volunteering_Mins_No_Name_Volunteer__c FROM Account WHERE Id IN :orgIds];
            for(Account c : accountList){
                system.debug('====ericca debug 0=====c.Total_Volunteering_Hours__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                if(newList != null){
                    for(Attendance__c att : newList){
                        Date cekout = Date.newInstance(att.Checked_Out__c.year(), att.Checked_Out__c.month(), att.Checked_Out__c.day());
                        Date cekin = Date.newInstance(att.Checked_In__c.year(), att.Checked_In__c.month(), att.Checked_In__c.day()); 
                        Long daysbetween = cekin.daysBetween(cekout) * 24 * 60;
                        Long min1 = daysbetween + (att.Checked_Out__c.hour() * 60 + att.Checked_Out__c.minute()) - (att.Checked_In__c.hour() * 60 + att.Checked_In__c.minute()); 
                        if(att.Organisation_Name__c == c.Id){
                            if(oldMap != null && oldMap.get(att.id) != null && (att.Organisation_Name__c != oldMap.get(att.id).Organisation_Name__c || att.Checked_Out__c <> oldMap.get(att.id).Checked_Out__c || att.Validated__c <> oldMap.get(att.id).Validated__c)){
                                // when update
                                if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                                    c.Volunteering_Mins_No_Name_Volunteer__c = c.Volunteering_Mins_No_Name_Volunteer__c == null ? 0 + min1 : c.Volunteering_Mins_No_Name_Volunteer__c + min1;
                                    system.debug('====ericca debug 1 =====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                                }
                                
                                if(oldMap.get(att.id).Checked_In__c != null && oldMap.get(att.id).Checked_Out__c != null && oldMap.get(att.id).Validated__c && att.Organisation_Name__c == oldMap.get(att.id).Organisation_Name__c ){
                                    Date cekout0 = Date.newInstance(oldMap.get(att.id).Checked_Out__c.year(), oldMap.get(att.id).Checked_Out__c.month(), oldMap.get(att.id).Checked_Out__c.day());
                        			Date cekin0 = Date.newInstance(oldMap.get(att.id).Checked_In__c.year(), oldMap.get(att.id).Checked_In__c.month(), oldMap.get(att.id).Checked_In__c.day()); 
                                    Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60;
                                    Long min0 = daysbetween0 + (oldMap.get(att.id).Checked_Out__c.hour() * 60 + oldMap.get(att.id).Checked_Out__c.minute()) - (oldMap.get(att.id).Checked_In__c.hour() * 60 + oldMap.get(att.id).Checked_In__c.minute()); 
                                    c.Volunteering_Mins_No_Name_Volunteer__c = c.Volunteering_Mins_No_Name_Volunteer__c == null ? 0 : c.Volunteering_Mins_No_Name_Volunteer__c - min0;
                                    system.debug('====ericca debug 2=====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                                }     
                            }else{ // when insert
                                if(oldMap == null || oldMap.get(att.Id) == null){
                                    if(att.Checked_In__c != null && att.Checked_Out__c != null  && att.Validated__c){
                                        c.Volunteering_Mins_No_Name_Volunteer__c = c.Volunteering_Mins_No_Name_Volunteer__c == null ? 0 + min1 : c.Volunteering_Mins_No_Name_Volunteer__c + min1;
                                        system.debug('====ericca debug 3=====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                                    }
                                }
                                
                            }
                        }else if(oldMap !=null && oldMap.get(att.id) != null && att.Organisation_Name__c != oldMap.get(att.id).Organisation_Name__c && oldMap.get(att.id).Organisation_Name__c == c.Id){
                            if(oldMap.get(att.id).Checked_In__c != null && oldMap.get(att.id).Checked_Out__c != null && oldMap.get(att.id).Validated__c){
                                Date cekout0 = Date.newInstance(oldMap.get(att.id).Checked_Out__c.year(), oldMap.get(att.id).Checked_Out__c.month(), oldMap.get(att.id).Checked_Out__c.day());
                                Date cekin0 = Date.newInstance(oldMap.get(att.id).Checked_In__c.year(), oldMap.get(att.id).Checked_In__c.month(), oldMap.get(att.id).Checked_In__c.day()); 
                                Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60 ;
                                Long min0 = daysbetween0 + (oldMap.get(att.id).Checked_Out__c.hour() * 60 + oldMap.get(att.id).Checked_Out__c.minute()) - (oldMap.get(att.id).Checked_In__c.hour() * 60 + oldMap.get(att.id).Checked_In__c.minute()); 
                                c.Volunteering_Mins_No_Name_Volunteer__c = c.Volunteering_Mins_No_Name_Volunteer__c == null ? 0 : c.Volunteering_Mins_No_Name_Volunteer__c - min0;
                                system.debug('====ericca debug 4=====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                            }
                        }
                    }
                }else{
                    for(Attendance__c att : oldMap.values()){
                        if(att.Organisation_Name__c == c.Id){
                            if(att.Checked_In__c != null && att.Checked_Out__c != null && att.Validated__c){
                                Date cekout0 = Date.newInstance(att.Checked_Out__c.year(), att.Checked_Out__c.month(), att.Checked_Out__c.day());
                                Date cekin0 = Date.newInstance(att.Checked_In__c.year(), att.Checked_In__c.month(), att.Checked_In__c.day()); 
                                Long daysbetween0 = cekin0.daysBetween(cekout0) * 24 * 60 ;
                                Long min0 = daysbetween0 + (att.Checked_Out__c.hour() * 60 + att.Checked_Out__c.minute()) - (att.Checked_In__c.hour() * 60 + att.Checked_In__c.minute()); 
                                c.Volunteering_Mins_No_Name_Volunteer__c = c.Volunteering_Mins_No_Name_Volunteer__c == null ? 0 : c.Volunteering_Mins_No_Name_Volunteer__c - min0;
                                system.debug('====ericca debug 5=====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
                            }
                        }
                    }
                }
                system.debug('====ericca debug 6=====c.Volunteering_Mins_No_Name_Volunteer__c for '+c.Name+':'+ c.Volunteering_Mins_No_Name_Volunteer__c);
            }
            update(accountList);
        }*/
    }
    //Total_Volunteering_Hours__c
}