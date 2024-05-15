package support.assignment0;

import support.robot.RobotModel;


/*
 * Translate robotic motions like forward and turn
 *   into actions on a RobotModel
 *   snaps to nearest 45 degree angle
 */

public class RobotMotionAdapter {
	
	private RobotModel model;
	public double forward;

	public RobotMotionAdapter(RobotModel model) {
		this.model = model;
	}
	
	public void forward(int pixels) {
		Vector oldVelocity = model.getVelocity();
//		Vector newVelocity = oldVelocity.scale(pixels);
// BSIEVER: Updated for proper scaling
		Vector newVelocity = oldVelocity.scale(pixels/oldVelocity.magnitude());

		model.setVelocity(newVelocity);
		model.step();
	}
	
	public void turnRight(int degrees) {
		turnLeft(-degrees);
	}
	
	public void turnLeft(int degrees) {
		Vector oldVelocity = model.getVelocity();
		double angle = oldVelocity.getAngle();
		
			
		
		Vector newVelocity = Vector.getUnitVector((int)(angle - degrees));
// BSIEVER: Removed the "snap" to increments of 90 degrees
//		model.setVelocity(newVelocity.snapTo());
		model.setVelocity(newVelocity);
	}

}
