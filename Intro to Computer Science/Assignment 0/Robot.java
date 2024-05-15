package support.robot;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.GeneralPath;
import javax.swing.*;
import support.cse131.Image2;

/**
 * A support.robot image that turns and moves under program control, typically using the
 * methods turnLeft(degrees), turnRight(degrees), and forward(pixels).
 * @author Kenneth J. Goldman
 * Created: July 24, 2007
 * Modified: July 28, 2009
 */

public class Robot extends Image2 implements ActionListener {
	private static final long serialVersionUID = 1L; // The version number for this class.
	String imageFile; // The name of the file containing the image of the support.robot.
	Timer timer = new Timer(50, this); // A timer that "ticks" 20 times per second (every 50 milliseconds) for support.robot animation.
	static int pixelsPerStep = 10; // The number of pixels to move forward at each time step (constant).
	Point destination; // The current destination of the support.robot, or null if the support.robot is not moving.
	double px, py;  // The current position of the support.robot, in pixels.
	double dx, dy;  // The change in x and y per move.
	double heading = 0; // in degrees 
	double newheading = 0;
	GeneralPath path = new GeneralPath(); // The "trail" that the support.robot leaves behind itself.
	double direction = 90;


	/**
	 * Creates a support.robot with the given image, centered at the given location, and with the given width and height.
	 * @param imageFile the file containing the image of the support.robot (ideally an animated gif)
	 * @param x the x-coordinate for the center of the support.robot
	 * @param y the y-coordinate for the center of the support.robot
	 * @param width the width of the support.robot (in pixels)
	 * @param height the height of the support.robot (in pixels)
	 */	

	public synchronized void changeSpeed(int speed){
		pixelsPerStep = speed;
	}

	public Robot(String imageFile, int x, int y, int width, int height) {
		super(width, height);
		setOpaque(false);
		super.setCenter(x, y);
		resetPath();
		path.moveTo(getCenterX(), getCenterY());
		setImageFile(imageFile);	
		timer.start();  // Start the timer to repain the animated gif and to handle support.robot motion.
	}

	/**
	 * Moves the support.robot forward the given distance.
	 * @param distance the number of pixels by which the support.robot should move forward.
	 */
	public synchronized void forward(int distance) {
		double radians = ((heading+270)%360) / 180 * Math.PI;
		double sin = Math.sin(radians);
		double cos = Math.cos(radians);
		if (sin == 0) {
			if (cos > 0)
				glideTo(getCenterX() + distance, getCenterY());
			else
				glideTo(getCenterX() - distance, getCenterY());
		} else if (cos == 0) {
			if (sin > 0)
				glideTo(getCenterX(), getCenterY() + distance);
			else
				glideTo(getCenterX(), getCenterY() - distance);
		} else
			glideTo(getCenterX() + (int) (cos*distance), getCenterY() + (int) (sin*distance));
	}

	/**
	 * Centers the support.robot at given coordinates.  This is an instantaneous move, without
	 * any animation.  This change in position does not leave a trail behind the support.robot.
	 * For animated motion, use either the "forward" or "glideTo" method.
	 */
	@Override
	public void setCenter(int x, int y) {
		super.setCenter(x,y);
		path.moveTo(x,y);
	}

	/**
	 * Centers the support.robot instantly at given coordinates, leaving a trail behind the support.robot,
	 * but without performing any animation.
	 * For animated motion, use either the "forward" or "glideTo" method.
	 */
	public void moveTo(int x, int y) {
		super.setCenter(x,y);
		path.lineTo(x, y);
		repaint();
	}


	/**
	 * Smoothly moves the support.robot to the given coordinates, without regard to the
	 * support.robot's current orientation.
	 * @param x the x-coordinate of the destination
	 * @param y the y-coordinate of the destination
	 */
	public synchronized void glideTo(double x, double y) {
		//First, set up the amount of motion for each "tick" of the timer.
		destination = new Point((int) x,(int) y);
		px = getCenterX();
		py = getCenterY();
		dx = destination.x - px;
		dy = destination.y - py;
		double distance = Math.sqrt(dx*dx + dy*dy);
		double steps = distance / pixelsPerStep;
		dx = dx / steps;
		dy = dy / steps;
		// Now, wait for the support.robot to arrive at its destination.
		while (destination != null) {
			try {
				wait();
			} catch (InterruptedException e) {}
		}
	}

	/**
	 * Clears away the "trail" that has been drawn behind the support.robot.
	 */
	public void resetPath() {
		path.reset();
		path.moveTo(getCenterX(), getCenterY());
		if (getParent() != null)
			getParent().repaint();
	}

	/**
	 * Gets the name of the image file.
	 * @return the imageFile
	 */
	public String getImageFile() {
		return imageFile;
	}

	/**
	 * Sets the name of the image file.
	 * @param imageFile the imageFile to set
	 */
	public void setImageFile(String imageFile) {
		this.imageFile = imageFile;
	}


	/**
	 * The paint method not only paints the image, but also paints the "trail" that
	 * the support.robot leaves behind it.
	 */
	@Override
	public void paint(Graphics g) {
		loadImage(imageFile);
		
		super.paint(g);
		if (getParent() != null) {	
			// BSIEVER: Changed stroke / color
			Graphics2D g2d = (Graphics2D)getParent().getGraphics();
			BasicStroke bs = new BasicStroke(3.0f);
			g2d.setStroke(bs);
			g2d.setColor(Color.BLACK);
			g2d.draw(path);
		}
	}

	public void changeHeading(double newHeading){
// BSIEVER: Change the sign (was -newHeading)
		this.setRotation(newHeading);  
		heading = newHeading;
		repaint();
	}

	/**
	 * This method is called at each "tick" of the timer.  If the support.robot is moving,
	 * this method performs one step of the move.  It also repaints the image to show the
	 * next frame of the animation.
	 */
	public synchronized void actionPerformed(ActionEvent arg0) {
		repaint();
		if (destination != null) {
			double distx = destination.x - getCenterX();
			double disty = destination.y - getCenterY();
			double dist = (int) Math.sqrt(distx*distx + disty*disty);
			if (dist > pixelsPerStep) {
				px = px + dx;
				py = py + dy;
				moveTo((int) px, (int) py);
				repaint();
			} else {
				moveTo(destination.x, destination.y);
				repaint();
				destination = null;
			}	
		} else {
			notify();
		}
	}

}
