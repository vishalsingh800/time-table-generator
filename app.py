# Add Subject
@app.route('/api/add-subject', methods=['POST'])
def add_subject():
    data = request.get_json()
    subject_code = data.get('subjectCode')
    subject_name = data.get('subjectName')
    faculty_name = data.get('facultyName')
    venue = data.get('venue')
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('INSERT INTO subjects (code, name, faculty, venue) VALUES (?, ?, ?, ?)', (subject_code, subject_name, faculty_name, venue))
        conn.commit()
        return jsonify({'message': 'Subject added successfully'})
    except Exception as e:
        print('Error adding subject:', e)
        return jsonify({'error': 'Failed to add subject'}), 500
    finally:
        conn.close()


import os
from flask import Flask, render_template, jsonify, request
from flask.cli import load_dotenv
import pyodbc

app = Flask(__name__)

# -------------------------
# Load environment variables
# -------------------------
load_dotenv()
conn_str = os.getenv("DB_CONNECTION_STRING")

# -------------------------
# Helper function for DB connection
# -------------------------
def get_db_connection():
    try:
        conn = pyodbc.connect(conn_str or
                              'DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=timetable;Trusted_Connection=yes;')
        return conn
    except pyodbc.Error as e:
        print(f"DB connection error: {e}")
        return None

# -------------------------
# Helper function to convert pyodbc rows to dict
# -------------------------
def rows_to_dict(cursor, rows):
    columns = [column[0] for column in cursor.description]
    return [dict(zip(columns, row)) for row in rows]

# -------------------------
# API routes for adding and fetching data
# -------------------------

# Add Course
@app.route('/api/add-course', methods=['POST'])
def add_course():
    data = request.get_json()
    name = data.get('name')
    section = data.get('section')
    department = data.get('department')
    color = data.get('color')
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('INSERT INTO courses (name, color, department) VALUES (?, ?, ?)', (name, color, department))
        course_id = cursor.execute('SELECT @@IDENTITY AS id').fetchone()[0]
        cursor.execute('INSERT INTO courseSections (courseID, section) VALUES (?, ?)', (course_id, section))
        conn.commit()
        return jsonify({'message': 'Course added successfully'})
    except Exception as e:
        print('Error adding course:', e)
        return jsonify({'error': 'Failed to add course'}), 500
    finally:
        conn.close()

# Add Room
@app.route('/api/add-room', methods=['POST'])
def add_room():
    data = request.get_json()
    room_number = data.get('room_number')
    building_name = data.get('building_name')
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT id FROM buildings WHERE name = ?', (building_name,))
        building = cursor.fetchone()
        if building:
            building_id = building[0]
        else:
            cursor.execute('INSERT INTO buildings (name) VALUES (?)', (building_name,))
            building_id = cursor.execute('SELECT @@IDENTITY AS id').fetchone()[0]
        cursor.execute('INSERT INTO rooms (room_number, building_id) VALUES (?, ?)', (room_number, building_id))
        conn.commit()
        return jsonify({'message': 'Room added successfully'})
    except Exception as e:
        print('Error adding room:', e)
        return jsonify({'error': 'Failed to add room'}), 500
    finally:
        conn.close()

# Add Instructor
@app.route('/api/add-instructor', methods=['POST'])
def add_instructor():
    data = request.get_json()
    name = data.get('name')
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('INSERT INTO instructors (name) VALUES (?)', (name,))
        conn.commit()
        return jsonify({'message': 'Instructor added successfully'})
    except Exception as e:
        print('Error adding instructor:', e)
        return jsonify({'error': 'Failed to add instructor'}), 500
    finally:
        conn.close()

# Get Courses
@app.route('/api/courses')
def get_courses():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('''
            SELECT c.id, c.name, c.color, c.department, s.section
            FROM courses c
            JOIN courseSections s ON c.id = s.courseID
        ''')
        rows = cursor.fetchall()
        courses = rows_to_dict(cursor, rows)
        return jsonify(courses)
    except Exception as e:
        print("Error fetching courses:", e)
        return jsonify({'error': 'Failed to fetch courses'}), 500
    finally:
        conn.close()

# Get Rooms
@app.route('/api/rooms')
def get_rooms():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('''
            SELECT r.id, r.room_number, b.name AS building_name
            FROM rooms r
            JOIN buildings b ON r.building_id = b.id
        ''')
        rows = cursor.fetchall()
        rooms = rows_to_dict(cursor, rows)
        return jsonify(rooms)
    except Exception as e:
        print("Error fetching rooms:", e)
        return jsonify({'error': 'Failed to fetch rooms'}), 500
    finally:
        conn.close()
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    result = None
    try:
        # Sample data
        courses = [
            {'name': 'Mathematics', 'color': '#e57373', 'department': 'Science', 'section': 'A'},
            {'name': 'Physics', 'color': '#64b5f6', 'department': 'Science', 'section': 'B'},
            {'name': 'Chemistry', 'color': '#81c784', 'department': 'Science', 'section': 'A'},
            {'name': 'English', 'color': '#ffd54f', 'department': 'Arts', 'section': 'C'},
            {'name': 'Computer Science', 'color': '#ba68c8', 'department': 'Engineering', 'section': 'A'}
        ]
        for c in courses:
            cursor.execute('INSERT INTO courses (name, color, department) VALUES (?, ?, ?)', (c['name'], c['color'], c['department']))
            course_id = cursor.execute('SELECT @@IDENTITY AS id').fetchone()[0]
            cursor.execute('INSERT INTO courseSections (courseID, section) VALUES (?, ?)', (course_id, c['section']))
        conn.commit()
        result = jsonify({'message': 'Sample courses inserted successfully'})
    except Exception as e:
        print('Error inserting sample courses:', e)
        result = jsonify({'error': 'Failed to insert sample courses'}), 500
    finally:
        conn.close()
    return result


@app.route('/api/students')
def get_students():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT * FROM Student')
        rows = cursor.fetchall()
        students = rows_to_dict(cursor, rows)
        return jsonify(students)
    except Exception as e:
        print("Error fetching students:", e)
        return jsonify({'error': 'Failed to fetch students'}), 500
    finally:
        conn.close()


@app.route('/api/student-enrollments')
def get_student_enrollments():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT * FROM StudentCourseEnrollment')
        rows = cursor.fetchall()
        enrollments = rows_to_dict(cursor, rows)
        return jsonify(enrollments)
    except Exception as e:
        print("Error fetching enrollments:", e)
        return jsonify({'error': 'Failed to fetch enrollments'}), 500
    finally:
        conn.close()


@app.route('/save-timetable', methods=['POST'])
def save_timetable():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        data = request.get_json()
        assigned_courses = data.get('assigned_courses', [])
        values = [(c['id'], c['start_time'], c['end_time'], c['room_number']) for c in assigned_courses]
        cursor.executemany('''
            INSERT INTO timeslots (course_name, start_time, end_time, room_number)
            VALUES (?, ?, ?, ?)
        ''', values)
        conn.commit()
        return jsonify({'message': 'Timetable saved successfully'})
    except Exception as e:
        print("Error saving timetable:", e)
        return jsonify({'error': 'Failed to save timetable'}), 500
    finally:
        conn.close()


@app.route('/reset-timetable', methods=['POST'])
def reset_timetable():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'No database connection'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute('DELETE FROM timeslots')
        conn.commit()
        return jsonify({'message': 'Timetable reset successfully'})
    except Exception as e:
        print("Error resetting timetable:", e)
        return jsonify({'error': 'Failed to reset timetable'}), 500
    finally:
        conn.close()


@app.route('/')
def index():
    return render_template('index.html')


# -------------------------
# Run the app
# -------------------------
if __name__ == '__main__':
    app.run(debug=True)
