let courses_Permanent = [];
let rooms_Permanent = [];
let students_Permanent = [];
let studentEnrollments_Permanent = [];
let timetableData = []; // Stores dropped courses

$(document).ready(function () {
    fetchAllData();

    // Generate timetable
    $('#generateTimetable').click(function () {
        const totalRooms = parseInt($('#totalRooms').val()) || 0;
        const classDuration = parseInt($('#classDuration').val()) || 0;
        const breakTime = parseInt($('#breakTime').val()) || 0;
        const totalDays = Math.min(parseInt($('#totalDays').val()) || 0, 7);
        const startTime = $('#startTime').val();
        const endTime = $('#endTime').val();

        generateTimetable(totalDays, classDuration, breakTime, startTime, endTime);
    });

    // Save timetable as PDF
    $('#saveTimetable').click(function () {
        const element = document.getElementById('timetableContainer');
        html2pdf(element);
    });

    // Save timetable to database
    $('#saveToDatabase').on('click', function () {
        $.ajax({
            type: 'POST',
            url: '/save-timetable',
            contentType: 'application/json;charset=UTF-8',
            data: JSON.stringify({ assigned_courses: timetableData.map(t => ({
                id: t.courseId,
                start_time: t.timeSlot.split('-')[0],
                end_time: t.timeSlot.split('-')[1],
                room_number: t.room
            })) }),
            success: function (response) {
                alert('✅ Timetable saved successfully!');
                console.log('DB Save Response:', response.message);
            },
            error: function (error) {
                console.error('❌ Error saving timetable:', error);
            }
        });
    });

    // Reset timetable
    $('#resetTimetable').on('click', function () {
        if (confirm('Are you sure you want to reset the timetable?')) {
            $.ajax({
                type: 'POST',
                url: '/reset-timetable',
                success: function (response) {
                    alert('✅ Timetable reset successfully!');
                    $('#timetableContainer').empty();
                    timetableData = [];
                },
                error: function (error) {
                    console.error('❌ Error resetting timetable:', error);
                }
            });
        }
    });
});

/* ------------------------- Fetch All Data ------------------------- */
async function fetchAllData() {
    try {
        const [coursesRes, roomsRes, studentsRes, enrollmentsRes] = await Promise.all([
            fetch('/api/courses'),
            fetch('/api/rooms'),
            fetch('/api/students'),
            fetch('/api/student-enrollments')
        ]);

        courses_Permanent = await coursesRes.json();
        rooms_Permanent = await roomsRes.json();
        students_Permanent = await studentsRes.json();
        studentEnrollments_Permanent = await enrollmentsRes.json();

        populateCoursesDrawer();
    } catch (error) {
        console.error('Error fetching data:', error);
        alert('❌ Failed to fetch data from server');
    }
}

/* ------------------------- Populate Courses Drawer ------------------------- */
function populateCoursesDrawer() {
    $('#coursesList').empty().append('<div id="coursesHeading">Courses List</div>');

    courses_Permanent.forEach(course => {
        $('#coursesList').append(`
            <div class="course" 
                 data-id="${course.id}" 
                 data-name="${course.name}" 
                 data-section="${course.section}" 
                 style="background-color: ${course.color || '#d1e7dd'};">
                ${course.name} (${course.section})
            </div>
        `);
    });

    // Make courses draggable
    $('.course').draggable({
        helper: 'clone',
        revert: 'invalid'
    });
}

/* ------------------------- Timetable Generation ------------------------- */
function generateTimetable(totalDays, classDuration, breakTime, startTime, endTime) {
    let timetableHtml = '<div class="day-tabs">';
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    for (let day = 0; day < totalDays; day++) {
        timetableHtml += `<span class="day-tab" onclick="switchDay(${day + 1})">${weekdays[day]}</span>`;
    }
    timetableHtml += '</div>';

    for (let day = 1; day <= totalDays; day++) {
        timetableHtml += `<table class="timetable" id="day${day}"><tr><th>Room / Time</th>`;

        let currentHour = parseInt(startTime.split(':')[0]);
        let currentMinute = parseInt(startTime.split(':')[1]);
        const endHour = parseInt(endTime.split(':')[0]);
        const endMinute = parseInt(endTime.split(':')[1]);

        // Header row
        while (true) {
            let slotEnd = addMinutes(currentHour, currentMinute, classDuration);
            if (slotEnd.hour > endHour || (slotEnd.hour === endHour && slotEnd.minute > endMinute)) break;
            timetableHtml += `<th>${formatTime(currentHour, currentMinute)}-${formatTime(slotEnd.hour, slotEnd.minute)}</th>`;
            const nextSlot = addMinutes(currentHour, currentMinute, classDuration + breakTime);
            currentHour = nextSlot.hour;
            currentMinute = nextSlot.minute;
        }
        timetableHtml += '</tr>';

        // Room rows
        rooms_Permanent.forEach(room => {
            timetableHtml += `<tr><td>${room.building_name} - ${room.room_number}</td>`;
            let currentHour = parseInt(startTime.split(':')[0]);
            let currentMinute = parseInt(startTime.split(':')[1]);

            while (true) {
                let slotEnd = addMinutes(currentHour, currentMinute, classDuration);
                if (slotEnd.hour > endHour || (slotEnd.hour === endHour && slotEnd.minute > endMinute)) break;

                timetableHtml += `<td class="time-slot" 
                                      data-time="${formatTime(currentHour, currentMinute)}-${formatTime(slotEnd.hour, slotEnd.minute)}" 
                                      data-day="${day}" 
                                      data-room="${room.room_number}">
                                  </td>`;

                const nextSlot = addMinutes(currentHour, currentMinute, classDuration + breakTime);
                currentHour = nextSlot.hour;
                currentMinute = nextSlot.minute;
            }
            timetableHtml += '</tr>';
        });
        timetableHtml += '</table>';
    }

    $('#timetableContainer').html(timetableHtml);
    $('.timetable').hide();
    $('#day1').show();
    setupDroppables();
    switchDay(1);
}

/* ------------------------- Drag & Drop ------------------------- */
function setupDroppables() {
    $('.timetable .time-slot').droppable({
        accept: ".course, .dropped-course",
        drop: function (event, ui) {
            const courseId = $(ui.draggable).data('id');
            const courseName = $(ui.draggable).data('name');
            const section = $(ui.draggable).data('section');
            const courseColor = $(ui.draggable).css('background-color');
            const timeSlot = $(this).data('time');
            const day = $(this).data('day');
            const room = $(this).data('room');

            if (!isCourseScheduled(courseId, timeSlot, day, room)) {
                $(this).append(`<div class="dropped-course" 
                                    data-id="${courseId}" 
                                    data-name="${courseName}" 
                                    data-section="${section}" 
                                    style="background-color:${courseColor};">
                                    ${courseName} (${section})
                                </div>`);

                timetableData.push({ courseId, courseName, section, timeSlot, day, room });

                $(this).find('.dropped-course').last().draggable({
                    helper: 'clone',
                    revert: "invalid"
                });
            } else {
                alert(`⚠ Clash: ${courseName} already scheduled in this slot/room.`);
            }
        }
    });

    $('#coursesList').droppable({
        accept: ".dropped-course",
        drop: function (event, ui) { ui.draggable.remove(); }
    });
}

/* ------------------------- Helpers ------------------------- */
function addMinutes(hour, minute, minsToAdd) {
    minute += minsToAdd;
    hour += Math.floor(minute / 60);
    minute %= 60;
    return { hour, minute };
}

function formatTime(hour, minute) {
    let period = "AM";
    if (hour >= 12) { period = "PM"; if (hour > 12) hour -= 12; }
    return `${hour.toString().padStart(2,'0')}:${minute.toString().padStart(2,'0')} ${period}`;
}

function switchDay(day) {
    $('.timetable').hide();
    $(`#day${day}`).show();
}

function isCourseScheduled(courseId, timeSlot, day, room) {
    return timetableData.some(entry =>
        entry.courseId === courseId && entry.timeSlot === timeSlot && entry.day === day && entry.room === room
    );
}

function toggleDrawer() {
    var drawer = document.getElementById("coursesList");
    var toggleButton = document.getElementById("toggleButton");
    if (drawer.style.left === "-250px") {
        drawer.style.left = "0px";
        toggleButton.style.left = "225px";
        toggleButton.innerHTML = "&#10094;";
    } else {
        drawer.style.left = "-250px";
        toggleButton.style.left = "0px";
        toggleButton.innerHTML = "&#10095;";
    }
}




