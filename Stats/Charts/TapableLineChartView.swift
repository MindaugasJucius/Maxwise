import Charts

class TapableLineChartView: LineChartView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGesture()
    }
    
    private func setupGesture() {
        let additionalTapGesture = UITapGestureRecognizer.init(
            target: self,
            action: #selector(handle(tapGesture:))
        )
        self.addGestureRecognizer(additionalTapGesture)
    }
    
    @objc private func handle(tapGesture: UITapGestureRecognizer) {
        guard tapGesture.state == .ended else {
            return
        }
        
        if !isHighLightPerTapEnabled { return }

        let location = tapGesture.location(in: self)
        
        let h = getHighlightByTouchPoint(location)

        guard !checkIfTappedOnMarker(tapLocation: location) else {
            lastHighlighted = nil
            highlightValue(nil, callDelegate: true)
            return
        }
                
        if h === nil || h == self.lastHighlighted
        {
            lastHighlighted = nil
            highlightValue(nil, callDelegate: true)
        }
        else
        {
            lastHighlighted = h
            highlightValue(h, callDelegate: true)
        }
    }
    
    private func checkIfTappedOnMarker(tapLocation: CGPoint) -> Bool {
        guard let highlight = lastHighlighted,
            let marker = marker as? LineChartMarkerView else {
            return false
        }
        
        let markerPosition = getMarkerPosition(highlight: highlight)
        
        let markerFrame = CGRect(
            x: markerPosition.x + marker.offset.x,
            y: markerPosition.y + marker.offset.y,
            width: marker.frame.width,
            height: marker.frame.height
        )

        guard markerFrame.contains(tapLocation) else {
            return false
        }

        return true
    }

}
