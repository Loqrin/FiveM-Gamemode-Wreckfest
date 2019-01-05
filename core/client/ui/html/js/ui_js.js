/**
ui_js.js 

This is a script file for the html UI. It handles the UI and sends and receives callbacks from the game.
**/

window.onload = function(e)
{
    function sortAsc(a, b)
    {
        return ($(b).text().toUpperCase()) < ($(a).text().toUpperCase()) ? 1 : -1;    
    }
    
    function sortDesc(a, b)
    {
        return ($(b).text().toUpperCase()) > ($(a).text().toUpperCase()) ? 1 : -1;    
    }

    //--#[Welcome Menu]#--\\
    function toggleWelcomeMenu(state)
    {
        if(state)
        {
            $("#welcome_menu_container").fadeIn("fast", "swing");
        }
        else
        {
            $("#welcome_menu_container").fadeOut("fast", "swing");
        }
    }

    $("#welcome_menu_btn_how2play").off("click").on("click", function(e)
    {
        console.log("[UI HTML Debug] :: Menu Not Implemented...");

        e.preventDefault();
    });

    $("#welcome_menu_btn_spawn").off("click").on("click", function(e)
    {
        $.post("http://loqscript_wreckfest_gamemode/spawnPlayer", JSON.stringify({}));

        toggleWelcomeMenu(false);

        e.preventDefault();
    });

    //--#[Blackout Menu]#--\\
    function toggleBlackoutMenu(state)
    {
        if(state)
        {
            $("#blackout_menu").fadeIn("fast", "swing");
        }
        else
        {
            $("#blackout_menu").fadeOut("fast", "swing");
        }
    }

    //--#[User Terminal]#--\\
    function updateUserTerminalTitlebar(text)
    {
        $("#user_terminal_titlebar span").text(text);
    }

    function updateUserTerminalNavHeading(text)
    {
        $("#user_terminal_nav_heading").text(text);
    }

    function appendUserTerminalNavList(key, item, sort)
    {
        if(sort)
        {
            $("#user_terminal_nav").append("<li class = '" + key + " sort'>" + item + "</li>");

            $("#user_terminal_nav .sort").sort(sortAsc).appendTo('#user_terminal_nav');
        }
        else
        {
            $("#user_terminal_nav").append("<li class = '" + key + " " + sort + "'>" + item + "</li>");
        }
    }

    function updateUserTerminalContentHeading(text)
    {
        $("#user_terminal_content_box_h").text(text);
    }

    function appendUserTerminalContentImage(image)
    {
        $("#user_terminal_content_box_imgs").append("<img src = 'imgs/" + image + "'></img>");
    }

    function updateUserTerminalContentText(text)
    {
        $("#user_terminal_content_box_text").html(text);
    }

    function clearUserTerminalNavList()
    {
        $("#user_terminal_nav").empty();
    }

    function clearUserTerminalContentImages()
    {
        $("#user_terminal_content_box_imgs").empty();
    }

    function toggleUserTerminal(state)
    {
        if(state)
        {
            $("#user_terminal_container").fadeIn("fast", "swing");
        }
        else
        {
            $("#user_terminal_container").fadeOut("fast", "swing");
        }
    }

    $("#user_terminal_exit_btn").off("click").on("click", function(e)
    {
        $.post("http://loqscript_wreckfest_gamemode/closeUserTerminal", JSON.stringify({}));

        e.preventDefault();
    });

    //--#[User Menu]#--\\
    var userMenuList
    var maxUserMenuItems = 15;

    var userMenuSelectedItem = 0, userMenuPreviousItem = -1;

    function updateUserMenuTitle(text)
    {
        $("#user_menu_title").text(text);
    }

    function appendUserMenuItem(key, item1, item2)
    {
        if(item2 == "none")
        {
            $("#user_menu_list").append("<li id = 'user_menu_item' class = '" + key + "'>" + item1 + "</li>");
        }
        else
        {
            $("#user_menu_list").append("<li id = 'user_menu_item' class = '" + key + "'>" + item1 + "<span style = 'float: right;'>" + item2 + "</span></li>");
        }
    }
    
    function finishUserMenuAppending()
    {
        userMenuSelectedItem = 0;
        userMenuPreviousItem = -1;

        userMenuList = $("#user_menu_list li").toArray();

        $("#user_menu_list li").slice(maxUserMenuItems).remove();
        userMenuList[0].classList.add("user_menu_selected_item");

        var val = userMenuList[0].textContent.split(":");

        $.post("http://loqscript_wreckfest_gamemode/userMenuSelectedItem", JSON.stringify({
            key: userMenuList[0].classList[0],
            item1: val[0],
            item2: val[1]
        }));

        $("#user_menu_container").fadeIn("fast", "swing");
    }

    function clearUserMenuList()
    {
        $("#user_menu_list").empty();
    }

    function scrollUserMenuDown()
    {
        if(userMenuSelectedItem < userMenuList.length - 1)
        {
            userMenuSelectedItem++;

            var val = userMenuList[userMenuSelectedItem].textContent.split(":");

            $.post("http://loqscript_wreckfest_gamemode/userMenuSelectedItem", JSON.stringify({
                key: userMenuList[userMenuSelectedItem].classList[0],
                item1: val[0],
                item2: val[1]
            }));

            if(userMenuSelectedItem <= maxUserMenuItems - 1)
            {
                userMenuList[userMenuSelectedItem].classList.add("user_menu_selected_item");
                userMenuList[userMenuSelectedItem - 1].classList.remove("user_menu_selected_item");
            }
            
            if(userMenuSelectedItem >= maxUserMenuItems - 1 && userMenuSelectedItem < userMenuList.length)
            {
                $("#user_menu_list").append(userMenuList[userMenuSelectedItem]);

                userMenuList[userMenuSelectedItem].classList.add("user_menu_selected_item");
                userMenuList[userMenuSelectedItem - 1].classList.remove("user_menu_selected_item");

                userMenuPreviousItem++;
                userMenuList[userMenuPreviousItem].remove();
            }
        }
    }

    function scrollUserMenuUp()
    {
        if(userMenuSelectedItem < maxUserMenuItems && userMenuSelectedItem > 0)
        {
            userMenuSelectedItem--;

            userMenuList[userMenuSelectedItem].classList.add("user_menu_selected_item");
            userMenuList[userMenuSelectedItem + 1].classList.remove("user_menu_selected_item");

            if(userMenuPreviousItem > -1)
            {
                $("#user_menu_list").prepend(userMenuList[userMenuPreviousItem]);

                userMenuPreviousItem--;
            }
        }

        if(userMenuSelectedItem > maxUserMenuItems - 1)
        {
            userMenuSelectedItem--;

            userMenuList[userMenuSelectedItem].classList.add("user_menu_selected_item");
            userMenuList[userMenuSelectedItem + 1].classList.remove("user_menu_selected_item");
            userMenuList[userMenuSelectedItem + 1].remove();

            $("#user_menu_list").prepend(userMenuList[userMenuPreviousItem]);

            userMenuPreviousItem--;
        }

        var val = userMenuList[userMenuSelectedItem].textContent.split(":");

        $.post("http://loqscript_wreckfest_gamemode/userMenuSelectedItem", JSON.stringify({
            key: userMenuList[userMenuSelectedItem].classList[0],
            item1: val[0],
            item2: val[1]
        }));
    }

    function updateUserMenuItem(key, text)
    {
        for(var i = 0; i < userMenuList.length; i++)
        {
            if(userMenuList[i].classList.contains(key))
            {
                var val = text.split(":");
                userMenuList[i].innerHTML = val[0] + ":<span style = 'float: right;'>" + val[1] + "</span>";

                $.post("http://loqscript_wreckfest_gamemode/userMenuSelectedItem", JSON.stringify({
                    key: userMenuList[i].classList[0],
                    item1: val[0],
                    item2: val[1]
                }));

                break;
            }
        }
    }

    function toggleUserMenu(state)
    {
        if(state)
        {
            $("#user_menu_container").fadeIn("fast", "swing");
        }
        else
        {
            $("#user_menu_container").fadeOut("fast", "swing");
        }
    }

    //--#[Scoreboard]#--\\
    function scoreboardAddPlyer(id, name, kills, deaths)
    {
        var splitID = id.split(":");

        $("#scoreboard_table").append("<tr id = 'scoreboard_tr' class = '" + splitID[1] + "'><td>" + name + "</td><td style = 'text-align: center;'>" + kills + "</td><td style = 'text-align: center;'>" + deaths + "</td></tr>");
    
        var sorted = $("#scoreboard_table tbody #scoreboard_tr").sort(function(a, b)
        {
            var a = $(a).find("td:nth-child(2)").text(), b = $(b).find("td:nth-child(2)").text();

            return b.localeCompare(a, false, {numeric: true})
        });

        $("#scoreboard_table tbody").empty();
        $("#scoreboard_table tbody").append("<th id = 'scoreboard_th_1'>Player</th><th id = 'scoreboard_th_2'>Kills</th><th id = 'scoreboard_th_3'>Deaths</th>");
        $("#scoreboard_table tbody").append(sorted);
    }

    function scoreboardUpdatePlyer(id, name, kills, deaths)
    {
        var splitID = id.split(":");

        $("." + splitID[1]).remove();
        $("#scoreboard_table").append("<tr id = 'scoreboard_tr' class = '" + splitID[1] + "'><td>" + name + "</td><td style = 'text-align: center;'>" + kills + "</td><td style = 'text-align: center;'>" + deaths + "</td></tr>");
    
        var sorted = $("#scoreboard_table tbody #scoreboard_tr").sort(function(a, b)
        {
            var a = $(a).find("td:nth-child(2)").text(), b = $(b).find("td:nth-child(2)").text();

            return b.localeCompare(a, false, {numeric: true})
        });

        $("#scoreboard_table tbody").empty();
        $("#scoreboard_table tbody").append("<th id = 'scoreboard_th_1'>Player</th><th id = 'scoreboard_th_2'>Kills</th><th id = 'scoreboard_th_3'>Deaths</th>");
        $("#scoreboard_table tbody").append(sorted);
    }

    function scoreboardTimer(duration, timerText)
    {
        var timer = duration, minutes, seconds;

        var timerInterval = setInterval(function()
        {
            minutes = parseInt(timer / 60, 10);
            seconds = parseInt(timer % 60, 10);

            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;

            $("#scoreboard_subtitle").text(timerText + ": " + minutes + ":" + seconds);

            if(--timer < 0)
            {
                clearInterval(timerInterval);
            }
        }, 1000);
    }

    function scoreboardClear()
    {
        $("#scoreboard_table tbody").empty();
    }

    function toggleScoreboard(state)
    {
        if(state)
        {
            $("#scoreboard_container").fadeIn("fast", "swing");
        }
        else
        {
            $("#scoreboard_container").fadeOut("fast", "swing");
        }
    }

    window.addEventListener("message", function(e)
    {
        var eventData = e.data;

        //--#[Welcome Menu]#--\\
        if(eventData.showWelcomeMenu)
        {
            toggleWelcomeMenu(true);
        }

        if(eventData.hideWelcomeMenu)
        {
            toggleWelcomeMenu(false);
        }

        //--#[Blackout Menu]#--\\
        if(eventData.showBlackoutMenu)
        {
            toggleBlackoutMenu(true);
        }

        if(eventData.hideBlackoutMenu)
        {
            toggleBlackoutMenu(false);
        }

        //--#[User Terminal]#--\\
        if(eventData.showUserTerminal)
        {
            toggleUserTerminal(true);
        }

        if(eventData.hideUserTerminal)
        {
            toggleUserTerminal(false);
        }

        if(eventData.detectUserTerminalMouseClick)
        {
            $("#user_terminal_nav li").off("click").on("click", function(e)
            {
                $.post("http://loqscript_wreckfest_gamemode/userTerminalNavClick", JSON.stringify({key: $(this).attr("class").split(" ")[0]}));

                e.preventDefault();
            });
        }

        if(eventData.updateUserTerminalTitlebar)
        {
            updateUserTerminalTitlebar(eventData.titleText);
        }

        if(eventData.updateUserTerminalNavHeading)
        {
            updateUserTerminalNavHeading(eventData.navHeading);
        }

        if(eventData.appendUserTerminalNavList)
        {
            appendUserTerminalNavList(eventData.key, eventData.item, eventData.sort);
        }

        if(eventData.updateUserTerminalContentHeading)
        {
            updateUserTerminalContentHeading(eventData.contentHeading);
        }

        if(eventData.appendUserTerminalContentImage)
        {
            appendUserTerminalContentImage(eventData.image);
        }

        if(eventData.updateUserTerminalContentText)
        {
            updateUserTerminalContentText(eventData.contentText);
        }

        if(eventData.clearUserTerminalNavList)
        {
            clearUserTerminalNavList();
        }

        if(eventData.clearUserTerminalContentImages)
        {
            clearUserTerminalContentImages();
        }

        //--#[User Menu]#--\\
        if(eventData.showUserMenu)
        {
            toggleUserMenu(true);
        }

        if(eventData.hideUserMenu)
        {
            toggleUserMenu(false);
        }

        if(eventData.updateUserMenuTitle)
        {
            updateUserMenuTitle(eventData.titleText);
        }

        if(eventData.appendUserMenuItem)
        {
            appendUserMenuItem(eventData.key, eventData.item1, eventData.item2);
        }

        if(eventData.finishUserMenuAppending)
        {
            finishUserMenuAppending();
        }

        if(eventData.clearUserMenuList)
        {
            clearUserMenuList();
        }

        if(eventData.scrollUserMenuDown)
        {
            scrollUserMenuDown();
        }

        if(eventData.scrollUserMenuUp)
        {
            scrollUserMenuUp();
        }

        if(eventData.updateUserMenuItem)
        {
            updateUserMenuItem(eventData.key, eventData.itemText);
        }

        //--#[Scoreboard]#--\\
        if(eventData.scoreboardAddPlyer)
        {
            scoreboardAddPlyer(eventData.plyerID, eventData.plyerName, eventData.plyerKills, eventData.plyerDeaths);
        }

        if(eventData.scoreboardUpdatePlyer)
        {
            scoreboardUpdatePlyer(eventData.plyerID, eventData.plyerName, eventData.plyerKills, eventData.plyerDeaths);
        }

        if(eventData.scoreboardUpdateTimer)
        {
            scoreboardTimer(eventData.duration, eventData.timerText);
        }
        
        if(eventData.scoreboardClear)
        {
            scoreboardClear();
        }

        if(eventData.showScoreboard)
        {
            toggleScoreboard(true);
        }

        if(eventData.hideScoreboard)
        {
            toggleScoreboard(false);
        }
    })
}